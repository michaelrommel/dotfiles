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

import { CustomEditor, type ExtensionAPI, type Theme } from '@mariozechner/pi-coding-agent';
import {
	CURSOR_MARKER,
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
	cw: { seq: '\x1bd', insert: true }, // delete word forward + insert mode
};

// Keys that start a combo (derived from COMBO_KEYS)
const COMBO_PREFIXES = new Set(Object.keys(COMBO_KEYS).map(k => k[0]!));

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

// Cursor style sequences within rendered lines:
// Normal mode: inverse video block (default editor style)
// Insert mode: replace inverse block with underline to mimic a bar cursor
const CURSOR_BLOCK_SEQ  = '\x1b[7m'; // inverse video  → block
const CURSOR_INSERT_SEQ = '\x1b[4m'; // underline      → bar

class ModalEditor extends CustomEditor {
	private mode: 'normal' | 'insert' = 'insert';
	private pendingKey: string | null = null;
	private appTheme: Theme;

	constructor(tui: TUI, editorTheme: EditorTheme, kb: KeybindingsManager, appTheme: Theme) {
		super(tui, editorTheme, kb);
		this.appTheme = appTheme;
	}

	private setCursorStyle(_mode: 'normal' | 'insert'): void {
		// no-op: cursor shape is handled in render() via line post-processing
	}

	handleInput(data: string): void {
		// Escape toggles to normal mode, or passes through for app handling
		if (matchesKey(data, 'escape')) {
			if (this.mode === 'insert') {
				this.mode = 'normal';
				this.setCursorStyle('normal');
			} else {
				this.setCursorStyle('insert'); // restore before handing off
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
					this.mode = 'insert';
					this.setCursorStyle('insert');
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
				this.mode = 'insert';
				this.setCursorStyle('insert');
			} else if (data === 'a') {
				this.mode = 'insert';
				this.setCursorStyle('insert');
				super.handleInput('\x1b[C'); // move right first
			} else if (data === 'A') {
				this.mode = 'insert';
				this.setCursorStyle('insert');
				super.handleInput('\x05'); // move to end of line first
			} else if (data === 'C') {
				this.mode = 'insert';
				this.setCursorStyle('insert');
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

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		// In insert mode, replace the block cursor (inverse video) with an underline
		// cursor, scoped to the exact cursor position via CURSOR_MARKER as anchor.
		if (this.mode === 'insert') {
			for (let i = 0; i < lines.length; i++) {
				const markerIdx = lines[i]!.indexOf(CURSOR_MARKER);
				if (markerIdx !== -1) {
					lines[i] = lines[i]!.replace(
						CURSOR_MARKER + CURSOR_BLOCK_SEQ,
						CURSOR_MARKER + CURSOR_INSERT_SEQ
					);
					break;
				}
			}
		}

		// Add mode indicator to bottom border
		const text   = this.mode === 'normal' ? ' NORMAL ' : ' INSERT ';
		const label  = this.mode === 'normal'
			? '\x1b[7m' + this.appTheme.fg('muted',  text) + '\x1b[27m'
			: '\x1b[7m' + this.appTheme.fg('accent', text) + '\x1b[27m';
		const labelWidth = visibleWidth(text); // measure raw text, not styled
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= labelWidth) {
			lines[last] =
				truncateToWidth(lines[last]!, width - labelWidth, '') + label;
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on('session_start', (_event, ctx) => {
		ctx.ui.setEditorComponent(
			(tui, editorTheme, kb) => new ModalEditor(tui, editorTheme, kb, ctx.ui.theme)
		);
	});
}
