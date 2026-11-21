/**
 * Modal Editor - vim-like modal editing example
 *
 * Usage: pi --extension ./examples/extensions/modal-editor.ts
 *
 * - Escape: insert → normal mode (in normal mode, aborts agent)
 * - i: normal → insert mode
 * - hjkl: navigation in normal mode
 * - ctrl+c, ctrl+d, etc. work in both modes
 */

import {
	CustomEditor,
	type ExtensionAPI,
	type Theme
} from '@mariozechner/pi-coding-agent';
import {
	type EditorTheme,
	type KeybindingsManager,
	matchesKey,
	truncateToWidth,
	type TUI,
	visibleWidth
} from '@mariozechner/pi-tui';

// Two-key combo mappings in normal mode: 'xy' -> { seq, insert? }
const COMBO_KEYS: Record<string, { seq: string; insert?: boolean }> = {
	dw: { seq: '\x1bd' }, // delete word forward (Meta+D)
	cw: { seq: '\x1bd', insert: true } // delete word forward + insert mode
};

// Keys that start a combo (derived from COMBO_KEYS)
const COMBO_PREFIXES = new Set(Object.keys(COMBO_KEYS).map((k) => k[0]!));

// Normal mode key mappings: key -> escape sequence (or null for mode switch)
const NORMAL_KEYS: Record<string, string | null> = {
	h: '\x1b[D', // left
	j: '\x1b[B', // down
	k: '\x1b[A', // up
	l: '\x1b[C', // right
	b: '\x1bb', // word left
	w: '\x1bf', // word right
	'0': '\x01', // line start
	$: '\x05', // line end
	x: '\x1b[3~', // delete char
	D: '\x0b', // delete to EOL (Ctrl+K)
	C: null, // delete to EOL + insert mode
	A: null, // end of line + insert mode
	i: null, // insert mode
	a: null // append (insert + right)
};

// Hardware cursor shape sequences (DECSCUSR, "CSI Ps SP q").
// With a real hardware cursor we no longer simulate the cursor inside the
// rendered text; instead we tell the terminal which shape to draw.
//   Normal mode -> steady block
//   Insert mode -> steady bar (vertical line)
//   Unfocused   -> reset to the terminal's default cursor
const CURSOR_SHAPE_BLOCK = '\x1b[2 q'; // steady block
const CURSOR_SHAPE_BAR = '\x1b[6 q'; // steady bar / line
const CURSOR_SHAPE_DEFAULT = '\x1b[0 q'; // terminal default

class ModalEditor extends CustomEditor {
	private mode: 'normal' | 'insert' = 'insert';
	private pendingKey: string | null = null;
	private appTheme: Theme;

	constructor(
		tui: TUI,
		editorTheme: EditorTheme,
		kb: KeybindingsManager,
		appTheme: Theme
	) {
		super(tui, editorTheme, kb);
		this.appTheme = appTheme;
	}

	// Switch mode and immediately re-assert the hardware cursor shape, so the
	// terminal matches the new mode without waiting for the next render pass.
	private setMode(mode: 'normal' | 'insert'): void {
		this.mode = mode;
		this.writeCursorShape();
	}

	handleInput(data: string): void {
		// Escape toggles to normal mode, or passes through for app handling
		if (matchesKey(data, 'escape')) {
			if (this.mode === 'insert') {
				this.setMode('normal');
			} else {
				super.handleInput(data); // abort agent, etc.
			}
			return;
		}

		// Insert mode: pass everything through
		if (this.mode === 'insert') {
			super.handleInput(data);
			return;
		}

		// Normal mode: resolve a pending combo key
		if (this.pendingKey !== null) {
			const combo = this.pendingKey + data;
			this.pendingKey = null;
			if (combo in COMBO_KEYS) {
				const { seq, insert } = COMBO_KEYS[combo]!;
				super.handleInput(seq);
				if (insert) {
					this.setMode('insert');
				}
			}
			// unrecognized combo: silently discard
			return;
		}

		// Normal mode: check if key starts a combo
		if (COMBO_PREFIXES.has(data)) {
			this.pendingKey = data;
			return;
		}

		// Normal mode: check mapped keys
		if (data in NORMAL_KEYS) {
			const seq = NORMAL_KEYS[data];
			if (data === 'i') {
				this.setMode('insert');
			} else if (data === 'a') {
				this.setMode('insert');
				super.handleInput('\x1b[C'); // move right first
			} else if (data === 'A') {
				this.setMode('insert');
				super.handleInput('\x05'); // move to end of line first
			} else if (data === 'C') {
				this.setMode('insert');
				super.handleInput('\x0b'); // delete to end of line first
			} else if (seq) {
				super.handleInput(seq);
			}
			return;
		}

		// Pass control sequences (ctrl+c, etc.) to super, ignore printable chars
		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	// Emit the DECSCUSR sequence for the current mode/focus state.
	//
	// This is deliberately unguarded ("self-healing"): the hardware cursor shape
	// is global terminal state that all sorts of things reset behind our back -
	// subprocesses and tools (pagers, $EDITOR, git), Ctrl+Z suspend/resume,
	// alt-screen switches, full repaints, resizes, and focus changes. A cache of
	// "the last shape we wrote" drifts out of sync with the real terminal and
	// then suppresses the write we actually needed, leaving the cursor shape and
	// the mode label disagreeing. Re-asserting the correct shape on every render
	// (and on every mode change) keeps the drift to at most one frame. The
	// sequence is tiny and does not cause visible flicker on conforming
	// terminals.
	private writeCursorShape(): void {
		const shape = !this.focused
			? CURSOR_SHAPE_DEFAULT
			: this.mode === 'normal'
				? CURSOR_SHAPE_BLOCK
				: CURSOR_SHAPE_BAR;
		this.tui.terminal.write(shape);
	}

	render(width: number): string[] {
		const lines = super.render(width);

		// Re-assert the hardware cursor shape every frame so it can never stay
		// stuck disagreeing with the mode label (see writeCursorShape).
		this.writeCursorShape();

		if (lines.length === 0) return lines;

		// Add mode indicator to bottom border
		const text = this.mode === 'normal' ? ' NORMAL ' : ' INSERT ';
		const label =
			this.mode === 'normal'
				? this.appTheme.fg('muted', '') +
					'\x1b[7m' +
					this.appTheme.fg('muted', text) +
					'\x1b[27m'
				: this.appTheme.fg('accent', '') +
					'\x1b[7m' +
					this.appTheme.fg('accent', text) +
					'\x1b[27m';
		const labelWidth = visibleWidth(text) + 1; // not styled, but with triangle
		//const num = last;
		const num = 0;
		if (visibleWidth(lines[num]!) >= labelWidth) {
			lines[num] = truncateToWidth(lines[num]!, width - labelWidth, '') + label;
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on('session_start', (_event, ctx) => {
		ctx.ui.setEditorComponent(
			(tui, editorTheme, kb) =>
				new ModalEditor(tui, editorTheme, kb, ctx.ui.theme)
		);
	});
}
