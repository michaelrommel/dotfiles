/**
 * TITS — Text Input To Speech
 *
 * A pi-coding-agent extension that reads LLM responses aloud via a local
 * Kokoros OpenAI-compatible TTS server.
 *
 * Architecture:
 *   message_update (text_delta events)
 *     └─► TextAccumulator        — buffers raw deltas, skips code blocks
 *           └─► filterForTTS()   — strips markdown/code from clean regions
 *                 └─► sentence boundary detection
 *                       └─► TTSPipeline.enqueue()
 *                             ├─► synthesizeText() → WAV bytes  (≤2 in parallel)
 *                             └─► playWav()        → afplay/aplay  (sequential)
 *
 *   Parallel synthesis, ordered playback:
 *   Up to MAX_CONCURRENT (2) synthesis requests run simultaneously, one per
 *   kokoros instance.  Playback consumes results in submission order so
 *   sentence N+1 is ready by the time sentence N finishes playing.
 *
 * Prerequisites:
 *   koko openai --instances 2 --port 3600
 *
 * Commands:
 *   /tits            — show status
 *   /tits on|off     — toggle
 *   /tits test       — play a test phrase
 */

import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { spawn } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import * as os from 'os';
import * as path from 'path';
import { appendFileSync } from 'node:fs';
import { writeFile, unlink } from 'node:fs/promises';

// ─── Debug Logging ───────────────────────────────────────────────────────────

/**
 * Set to true to write a per-session chunk + filter log to /tmp.
 * Each session creates a file like /tmp/pi-chunks-<timestamp>.log containing:
 *   --- chunk N ---     raw LLM delta (ev.delta)
 *   --- filter:in ---   text passed into filterForTTS() inside scan()
 *   --- filter:out ---  text returned by filterForTTS()
 *   --- sentence ---    sentence emitted to the TTS pipeline
 */
const CHUNK_LOGGING = false;

/** Module-level path so TextAccumulator.scan() can write without a closure. */
let _dbgLog: string | null = null;

function dbgAppend(line: string): void {
	if (_dbgLog) appendFileSync(_dbgLog, line);
}

// ─── Configuration ───────────────────────────────────────────────────────────

const TTS_BASE_URL = 'http://localhost:3600';
// const TTS_VOICE = 'sf_misspunnypennie';
const TTS_VOICE = 'bf_isabella.5+bf_emma.5';
const TTS_SPEED = 1.3;
const TTS_LANG = 'en-GB-x-rp';
const STATUS_KEY = 'tits';

/**
 * Minimum word count a sentence must have before it is sent for synthesis.
 * Prevents synthesizing single-word orphans like "Sure." or "Yes."
 */
const MIN_SENTENCE_WORDS = 5;

/**
 * Minimum accumulated raw-text size (in characters) before filterForTTS() is
 * invoked inside TextAccumulator.scan().
 *
 * LLMs often stream 3–10 character deltas, which means a pattern like
 * `^#{1,6}\s+` (ATX header) or `\`code\`` can arrive split across several
 * consecutive chunks.  By deferring the filter call until either:
 *   (a) the unprocessed raw buffer has grown past this threshold, OR
 *   (b) it contains a newline (needed immediately for line-level patterns)
 * we ensure the regex always sees a meaningful slice of text.
 *
 * Latency impact: at ~5 chars/chunk the first filter call fires after ~16
 * deltas (~80 ms at typical streaming rates) — well within synthesis latency.
 */
const MIN_FILTER_CHUNK = 80;

/**
 * Backtick-span substitutions applied before any other filtering.
 *
 * When the exact string on the left appears in the text, it is replaced with
 * the word on the right.  This covers punctuation-only or symbol-only inline
 * code spans that would otherwise be stripped or spoken unintelligibly.
 *
 * Matching is literal (no regex), case-sensitive, and applied in order.
 * Add entries here whenever a specific sequence sounds poor in practice.
 */
const TTS_SUBSTITUTIONS: Array<[string, string]> = [
	['`.`', 'dot'], // e.g. "no `. ` trim"
	['`. `', 'dot'], // e.g. "no `. ` trim"
	['`_`', 'underscore'], // e.g. "the `_ ` character"
	['`_ `', 'underscore'] // e.g. "the `_ ` character"
];

// ─── Text Filtering ───────────────────────────────────────────────────────────

/**
 * Strip markdown and code artefacts, returning text suitable for speech.
 *
 * Called only on text that has already been determined to lie outside an
 * incomplete fenced code block (see isInsideIncompleteCodeBlock).
 *
 * Handles (in order):
 *  1. Complete fenced blocks  — ```...``` and ~~~...~~~
 *  2. Inline code             — single-word `name` kept; multi-word `phrase` removed
 *  3. Markdown images         — ![alt](url)
 *  4. Markdown links          — [label](url) → label
 *  5. Bare URLs               — https://...
 *  6. ATX headers             — # ## ### …
 *  7. Bold markers            — ** and __ deleted (marker-only, no capture)
 *  8. Italic markers          — * and _ deleted (marker-only, no capture)
 *  9. Horizontal rules        — --- / *** / ___
 * 10. Blockquotes             — > …
 * 11. List item prefixes      — - / * / + / 1.
 * 12. Whitespace normalisation
 */
function filterForTTS(text: string): string {
	// 0. Pronounceable substitutions — applied first so the backtick delimiters
	//    are still present and the match is unambiguous.
	for (const [from, to] of TTS_SUBSTITUTIONS) {
		text = text.split(from).join(to);
	}

	// 1. Complete fenced code blocks (non-greedy so balanced pairs match first)
	text = text.replace(/```[\s\S]*?```/g, ' ');
	text = text.replace(/~~~[\s\S]*?~~~/g, ' ');

	// 1.5. Complete think blocks (both angle-bracket and escaped variants)
	text = text.replace(/<think>[\s\S]*?<\/think>/gi, ' ');
	text = text.replace(/&lt;think&gt;[\s\S]*?&lt;\/think&gt;/gi, ' ');

	// 2. Inline code:
	//    Single-word backtick spans (no whitespace) are spoken — e.g. `sox`, `null`, `git`.
	//    Functions are spoken — e.g. `fetch()`.
	//    Multi-word spans (contain whitespace) are removed — e.g. `npm install foo`.
	text = text.replace(/`([^\s`\n]+)`/g, '$1');
	text = text.replace(/`([^\s`\n]+\(\))`/g, 'function $1');
	//text = text.replace(/`[^`\n]+`/g, ' ');

	// 3. Markdown images
	text = text.replace(/!\[[^\]]*\]\([^)]*\)/g, ' ');

	// 4. Markdown links — keep the visible label
	text = text.replace(/\[([^\]]+)\]\([^)]*\)/g, '$1');

	// 5. Bare URLs
	text = text.replace(/https?:\/\/\S+/g, ' ');

	// 6. ATX headers
	text = text.replace(/^#{1,6}\s+/gm, '');

	// 6.5 List item separators — must run BEFORE bold/italic stripping (step 7-8)
	//     because * is used as a bullet marker and would be removed by step 8.
	//     Replace: last-non-whitespace-char-of-line + \n + optional-indent + list-marker
	//           →  that char + ". " + capitalised first char of the item.
	//     This injects a sentence boundary so extractSentences() splits between items.
	//     Works for unordered (-, *, +) and ordered (1., 2., …) markers.
	// When the preceding line already ends with punctuation (.!?:) just
	// capitalise — adding a second period would produce odd speech like "colon period".
	text = text.replace(/(\S)\n\s*(?:[-*+]|\d+\.)\s+(\S)/g, (_, prev, first) =>
		/[.!?:]/.test(prev)
			? `${prev} ${first.toUpperCase()}`
			: `${prev}. ${first.toUpperCase()}`
	);

	// 7. Bold — delete ** and __ markers outright.
	//    A paired regex like /\*\*([^*]+)\*\*/ only works when both markers
	//    land in the same chunk. Because filterForTTS is called on each newly
	//    scanned chunk independently, bold text split across two scans would
	//    leave raw ** in the output. Deleting markers unconditionally is
	//    chunk-boundary-safe and still produces the correct spoken result.
	text = text.replace(/\*\*/g, '');
	text = text.replace(/__/g, '');

	// 8. Italic — delete remaining lone * and _.
	//    List-item bullets (*) are stripped below (^[-*+]\s+), so any
	//    surviving * at this point is an emphasis marker or stray artefact.
	text = text.replace(/\*/g, '');
	text = text.replace(/_/g, '');

	// 9. Horizontal rules
	text = text.replace(/^[-*_]{3,}\s*$/gm, ' ');

	// 10. Blockquote markers — inject a sentence break before each blockquote
	//     line, mirroring step 6.5 for list items.  Without this, a line like
	//     "> Note:" would run straight onto the previous sentence with no pause.
	//     When the preceding line already ends with punctuation, just capitalise.
	text = text.replace(/(\S)\n\s*>\s*(\S)/g, (_, prev, first) =>
		/[.!?:]/.test(prev)
			? `${prev} ${first.toUpperCase()}`
			: `${prev}. ${first.toUpperCase()}`
	);
	// Strip any remaining > markers (first line of a block, or chunk-split cases
	// handled cross-chunk by startsNewListItem).
	text = text.replace(/^>\s*/gm, '');

	// 11. Strip any list markers still present (first item, or items whose
	//     first char wasn't captured by the separator regex in step 6.5).
	text = text.replace(/^[-*+]\s+/gm, '');
	text = text.replace(/^\d+\.\s+/gm, '');

	// 12. Collapse newlines → spaces; collapse runs of spaces
	text = text.replace(/\n+/g, ' ').replace(/\s{2,}/g, ' ');

	return text;
}

/**
 * Returns true if `text` ends inside an unclosed fenced code block or
 * think block.
 *
 * Scans linearly for ``` / ~~~ triple-character sequences and
 * <think> / &lt;think&gt; think-tag sequences.  Each fence toggles the
 * open/closed state; the language-specifier line after an opening code
 * fence is skipped so its content does not trigger a spurious close.
 *
 * Used by TextAccumulator.scan() to defer processing until the block closes.
 */
function isInsideIncompleteCodeBlock(text: string): boolean {
	let inBlock = false;
	let inThink = false;
	let pos = 0;

	while (pos < text.length) {
		// Find the earliest fence or think-tag start
		const tb = text.indexOf('```', pos);
		const tt = text.indexOf('~~~', pos);
		const th = text.indexOf('<think>', pos);
		const thEsc = text.indexOf('&lt;think&gt;', pos);

		// Collect candidates (ignore -1 = not found)
		const candidates: number[] = [];
		if (tb !== -1) candidates.push(tb);
		if (tt !== -1) candidates.push(tt);
		if (th !== -1) candidates.push(th);
		if (thEsc !== -1) candidates.push(thEsc);
		if (candidates.length === 0) break;

		const next = Math.min(...candidates);

		// Only treat ``` / ~~~ as fences when at the start of a line
		// (at most 3 spaces/tabs of indent — CommonMark rule).
		// <think> / &lt;think&gt; tags are treated as fences regardless of
		// position (they are XML-style self-contained tags, not line-based).
		const isFence = tb === next || tt === next;
		if (isFence) {
			const lineStart = text.lastIndexOf('\n', next - 1) + 1;
			const indent = text.slice(lineStart, next);
			if (!/^[ \t]{0,3}$/.test(indent)) {
				pos = next + (tb === next ? 3 : 3);
				continue;
			}
		}

		// Determine which kind of block was found and toggle state
		if (tb === next) {
			inBlock = !inBlock;
			pos = next + 3;
			if (inBlock) {
				const nl = text.indexOf('\n', pos);
				if (nl !== -1) pos = nl + 1;
			}
		} else if (tt === next) {
			inBlock = !inBlock;
			pos = next + 3;
			if (inBlock) {
				const nl = text.indexOf('\n', pos);
				if (nl !== -1) pos = nl + 1;
			}
		} else if (th === next) {
			inThink = !inThink;
			pos = next + '<think>'.length;
		} else if (thEsc === next) {
			inThink = !inThink;
			pos = next + '&lt;think&gt;'.length;
		}
	}

	return inBlock || inThink;
}

// ─── Text Accumulator ─────────────────────────────────────────────────────────

/**
 * Processes streaming text_delta events and emits complete sentences ready
 * for TTS synthesis.
 *
 * Internal state:
 *   rawBuffer    — every character received via feed(), including code blocks.
 *   lastScanPos  — how much of rawBuffer has been processed into pendingClean.
 *   pendingClean — filtered text waiting for a sentence boundary.
 *
 * Invariant: lastScanPos is only advanced when the raw buffer is NOT inside
 * an incomplete code block, ensuring we never emit filtered text that was
 * mid-block at the time of the scan.
 */
class TextAccumulator {
	private rawBuffer = '';
	private lastScanPos = 0;
	private pendingClean = '';

	/**
	 * Feed a new streaming text delta.
	 * @returns zero or more complete sentences ready for TTS.
	 */
	feed(delta: string): string[] {
		this.rawBuffer += delta;
		return this.scan();
	}

	/**
	 * Flush remaining buffered text at message_end.
	 * Returns any leftover text as a final sentence (if long enough).
	 */
	flush(): string[] {
		// Process any unscanned raw tail
		const tail = this.rawBuffer.slice(this.lastScanPos);
		this.lastScanPos = this.rawBuffer.length;

		if (tail.trim()) {
			// Mirror the cross-chunk list boundary check from scan() — the tail
			// arrives here when message_end fires before the last list item was
			// fed through feed(), so startsNewListItem() was never called for it.
			if (this.startsNewListItem(tail)) {
				const trimmed = this.pendingClean.trimEnd();
				if (trimmed) {
					this.pendingClean = trimmed + (/[.!?:]$/.test(trimmed) ? ' ' : '. ');
				}
			}
			const cleaned = filterForTTS(tail);
			if (cleaned.trim()) {
				this.pendingClean += cleaned;
			}
		}

		// Run the normal sentence extractor first — the flushed tail may contain
		// multiple sentences (e.g. post-code-block content, trailing list items).
		const sentences = this.extractSentences();

		// Emit whatever didn't end with a boundary as a final fragment.
		const remainder = this.pendingClean.trim();
		this.pendingClean = '';

		if (remainder && remainder.split(/\s+/).filter(Boolean).length >= 2) {
			sentences.push(remainder);
		}

		return sentences;
	}

	/** Reset all state before processing a new assistant message. */
	reset(): void {
		this.rawBuffer = '';
		this.lastScanPos = 0;
		this.pendingClean = '';
	}

	// ── Private ────────────────────────────────────────────────────────────────

	private scan(): string[] {
		// When we're inside an incomplete fenced block, flush any accumulated
		// clean text immediately rather than holding it hostage until the block
		// closes.  This ensures that a sentence ending with `:` (e.g. an intro
		// line before a code block) is spoken without delay.
		if (isInsideIncompleteCodeBlock(this.rawBuffer)) {
			const pending = this.pendingClean.trim();
			if (pending) {
				this.pendingClean = '';
				return pending.split(/\s+/).filter(Boolean).length >= MIN_SENTENCE_WORDS
					? [pending]
					: [];
			}
			return [];
		}

		const newChunk = this.rawBuffer.slice(this.lastScanPos);
		if (!newChunk) return [];

		// Defer filtering until we have enough raw text to satisfy multi-token
		// regex patterns (e.g. `^#{1,6}\s+` needs "###" + the following space).
		// Exception: process immediately when a newline is present, because
		// line-level patterns (headers, list items, blockquotes) need it to fire.
		if (newChunk.length < MIN_FILTER_CHUNK && !newChunk.includes('\n')) {
			return [];
		}

		// Inject a list-item sentence break for cross-chunk boundaries.
		// filterForTTS step 6.5 handles the case where both the end of the previous
		// item and the start of the next are in the same chunk.  When the \n lands
		// in one chunk and the list marker in the next (common in streaming), step
		// 6.5 never sees the pair together.  This stateful check catches that.
		if (this.startsNewListItem(newChunk)) {
			const trimmed = this.pendingClean.trimEnd();
			if (trimmed) {
				this.pendingClean = trimmed + (/[.!?:]$/.test(trimmed) ? ' ' : '. ');
			}
		}

		// Filter the newly available raw text and accumulate into pendingClean
		dbgAppend(`\n--- filter:in ---\n${JSON.stringify(newChunk)}\n`);
		const cleaned = filterForTTS(newChunk);
		dbgAppend(`--- filter:out ---\n${JSON.stringify(cleaned)}\n`);
		this.pendingClean += cleaned;
		this.lastScanPos = this.rawBuffer.length;

		return this.extractSentences();
	}

	/**
	 * Extract complete sentences from pendingClean.
	 *
	 * Sentence boundary heuristic:
	 *   [.!?:]+ followed by whitespace and a capital letter or opening quote.
	 *
	 * Colon is included so that introductory phrases like
	 * "...with a concurrency semaphore: The next step is..." are split
	 * at the colon rather than accumulating until flush.
	 *
	 * The capital-letter lookahead avoids false splits on mid-sentence
	 * abbreviations like "Dr. Smith" or "e.g. this approach" where the next
	 * word starts in lowercase, and on time/ratio literals like "10:30 am"
	 * where the character after `:` is a digit.
	 */
	private extractSentences(): string[] {
		const sentences: string[] = [];
		// Lookahead: capital ASCII, Unicode opening quotes ('' "")
		const re = /[.!?:]+\s+(?=[A-Z\u2018\u201C"'`])/g;

		let lastEnd = 0;
		let m: RegExpExecArray | null;

		while ((m = re.exec(this.pendingClean)) !== null) {
			const end = m.index + m[0].length;
			const sentence = this.pendingClean.slice(lastEnd, end).trim();
			const words = sentence.split(/\s+/).filter(Boolean).length;

			if (words >= MIN_SENTENCE_WORDS) {
				sentences.push(sentence);
				lastEnd = end;
			}
		}

		// Keep unmatched tail for the next delta
		this.pendingClean = this.pendingClean.slice(lastEnd);
		return sentences;
	}

	/**
	 * Returns true when newChunk starts a new list item whose \n boundary was
	 * NOT inside the same chunk (so filterForTTS step 6.5 couldn't handle it).
	 *
	 * Case B1: the last processed char in rawBuffer was \n, and newChunk starts
	 *          with a list marker — the classic token-by-token split.
	 * Case B2: newChunk itself starts with \n + list marker but has no \S before
	 *          the \n, so step 6.5's (\S)\n pattern can't match it.
	 */
	private startsNewListItem(newChunk: string): boolean {
		// Matches unordered/ordered list markers AND blockquote markers so that
		// cross-chunk blockquote boundaries get the same punctuation injection
		// as list items (mirrors filterForTTS step 10).
		const marker = /^[ \t]{0,3}(?:[-*+]|\d+\.|>)\s/;
		// Case B1
		const prevChar =
			this.lastScanPos > 0 ? this.rawBuffer[this.lastScanPos - 1] : '';
		if (prevChar === '\n' && marker.test(newChunk)) return true;
		// Case B2
		if (
			/^[ \t]*\n/.test(newChunk) &&
			marker.test(newChunk.replace(/^[ \t]*\n/, ''))
		)
			return true;
		return false;
	}
}

// ─── TTS HTTP Client ──────────────────────────────────────────────────────────

/**
 * POST `text` to the Kokoros OpenAI-compatible server and return WAV bytes.
 *
 * Uses `response_format: "wav"` so the response is a self-contained WAV file
 * playable directly by afplay / aplay without extra flags.
 */
async function synthesizeText(
	text: string,
	signal?: AbortSignal
): Promise<Uint8Array> {
	// dbg(`[speak] ${JSON.stringify(text)}`);
	const res = await fetch(`${TTS_BASE_URL}/v1/audio/speech`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify({
			model: 'tts-1',
			input: text,
			voice: TTS_VOICE,
			lang_code: TTS_LANG,
			speed: TTS_SPEED,
			response_format: 'wav'
		}),
		signal
	});

	if (!res.ok) {
		const body = await res.text().catch(() => '');
		throw new Error(
			`TTS server error ${res.status}: ${body || res.statusText}`
		);
	}

	return new Uint8Array(await res.arrayBuffer());
}

/**
 * Returns true if the TTS server responds to a root GET within 3 seconds.
 * The Kokoros server returns "OK" from `GET /`.
 */
async function checkConnectivity(): Promise<boolean> {
	try {
		const res = await fetch(`${TTS_BASE_URL}/`, {
			signal: AbortSignal.timeout(3000)
		});
		return res.ok;
	} catch {
		return false;
	}
}

// ─── Audio Playback ───────────────────────────────────────────────────────────

/**
 * Platform-specific audio player.
 * Returns `null` when no supported player is known for this platform.
 *
 * afplay (macOS) and aplay (Linux ALSA) both accept a WAV file path as their
 * sole positional argument and exit with code 0 on success.
 */
function platformPlayer(): string | null {
	if (process.platform === 'darwin') return 'afplay';
	if (process.platform === 'linux') return 'aplay';
	return null;
}

/**
 * Write WAV bytes to a temp file, play it to completion, then delete the file.
 *
 * Using a temp file (rather than piping) because:
 *  - afplay does not support reading WAV from stdin.
 *  - aplay supports stdin (`aplay -`) but requires explicit format flags;
 *    using a file lets both players auto-detect the WAV header.
 */
async function playWav(wav: Uint8Array): Promise<void> {
	const player = platformPlayer();
	if (!player) {
		console.warn(
			'[tits] No audio player available on platform:',
			process.platform
		);
		return;
	}

	const tmp = join(
		tmpdir(),
		`tits-${Date.now()}-${Math.random().toString(36).slice(2)}.wav`
	);

	try {
		await writeFile(tmp, wav);
		await new Promise<void>((resolve, reject) => {
			const proc = spawn(player, [tmp], { stdio: 'ignore' });
			proc.on('close', (code) =>
				code === 0 || code === null
					? resolve()
					: reject(new Error(`${player} exited ${code}`))
			);
			proc.on('error', reject);
		});
	} finally {
		// Best-effort cleanup — ignore ENOENT / race conditions
		unlink(tmp).catch(() => {});
	}
}

// ─── TTS Pipeline ─────────────────────────────────────────────────────────────

type PipelineState = 'synthesizing' | 'playing' | 'idle';

/** Maximum simultaneous synthesis HTTP requests — matches kokoros --instances. */
const MAX_CONCURRENT = 2;

/**
 * Parallel-synthesis, ordered-playback TTS pipeline.
 *
 * Concurrency model:
 *   Up to MAX_CONCURRENT synthesis requests run in parallel, one per kokoros
 *   instance.  Each enqueued sentence immediately gets a Promise<WAV> that is
 *   stored in `orderedQueue` at its submission position.
 *
 *   The playback loop (runPlay) consumes orderedQueue front-to-back, awaiting
 *   each Promise in turn.  Because the Promises are resolved concurrently,
 *   sentence N+1's WAV is typically ready the moment sentence N finishes
 *   playing — zero gap between sentences.
 *
 *   Ordering guarantee:
 *     orderedQueue[i] is always the Promise for the i-th submitted sentence.
 *     runPlay awaits them in index order, so audio plays in submission order
 *     regardless of which synthesis request finishes first.
 *
 *   Back-pressure:
 *     When MAX_CONCURRENT requests are already in-flight, new sentences wait
 *     in `waitQueue`.  Each time a synthesis request completes it pulls the
 *     next entry from waitQueue, keeping the pipeline fully loaded.
 */
class TTSPipeline {
	/** Synthesis Promises in submission order; runPlay consumes from the front. */
	private orderedQueue: Array<Promise<Uint8Array | null>> = [];
	/** Sentences waiting for a free synthesis slot. */
	private waitQueue: Array<{ text: string; signal?: AbortSignal }> = [];
	/** Number of synthesis HTTP requests currently in-flight (≤ MAX_CONCURRENT). */
	private inFlight = 0;
	private playRunning = false;
	private onState: (s: PipelineState) => void;

	constructor(onState: (s: PipelineState) => void) {
		this.onState = onState;
	}

	/**
	 * Enqueue `text` for synthesis and playback.
	 * Starts synthesis immediately if a slot is free; otherwise queues it.
	 */
	enqueue(text: string, signal?: AbortSignal): void {
		if (this.inFlight < MAX_CONCURRENT) {
			this.startSynthesis(text, signal);
		} else {
			this.waitQueue.push({ text, signal });
		}
		void this.runPlay();
	}

	/**
	 * Discard all pending work.
	 * In-flight synthesis requests complete but their results are dropped
	 * (orderedQueue is cleared so runPlay will not reach them).
	 * Currently playing audio finishes naturally.
	 */
	clear(): void {
		this.waitQueue = [];
		this.orderedQueue = [];
	}

	get isBusy(): boolean {
		return (
			this.inFlight > 0 || this.orderedQueue.length > 0 || this.playRunning
		);
	}

	// ── Private ────────────────────────────────────────────────────────────────

	/**
	 * Start one synthesis request and push its Promise onto orderedQueue.
	 * When it settles, pull the next waiting sentence into the freed slot.
	 */
	private startSynthesis(text: string, signal?: AbortSignal): void {
		this.inFlight++;
		this.onState('synthesizing');

		const p: Promise<Uint8Array | null> = synthesizeText(text, signal)
			.then((wav) => wav)
			.catch((err) => {
				if (!isAbortError(err)) console.error('[tits] Synthesis error:', err);
				return null; // null slot → runPlay skips playback for this sentence
			})
			.finally(() => {
				this.inFlight--;
				const next = this.waitQueue.shift();
				if (next) this.startSynthesis(next.text, next.signal);
			});

		this.orderedQueue.push(p);
	}

	/**
	 * Play sentences in submission order.
	 * Awaits each Promise in orderedQueue front-to-back.  A Promise resolved
	 * ahead of time (synthesis finished while an earlier sentence was playing)
	 * yields immediately — no inter-sentence gap.
	 */
	private async runPlay(): Promise<void> {
		if (this.playRunning) return;
		this.playRunning = true;
		try {
			while (this.orderedQueue.length > 0) {
				const p = this.orderedQueue.shift()!;
				const wav = await p; // wait for this sentence's synthesis
				if (wav !== null) {
					this.onState('playing');
					await playWav(wav);
				}
			}
		} catch (err) {
			console.error('[tits] Playback error:', err);
		} finally {
			this.playRunning = false;
			// Re-enter if sentences arrived while we were in the final drain check
			if (this.orderedQueue.length > 0) void this.runPlay();
			else this.onState('idle');
		}
	}
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function isAbortError(err: unknown): boolean {
	return (
		err instanceof Error &&
		(err.name === 'AbortError' || err.name === 'TimeoutError')
	);
}

// ─── Extension Factory ────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// Global enable flag — false until a successful connectivity check
	let enabled = false;

	let chunkIndex = 0;

	// setStatus is wired up in session_start once ctx is available
	let setUiStatus: ((text: string | undefined) => void) | null = null;

	const accumulator = new TextAccumulator();

	const pipeline = new TTSPipeline((state) => {
		switch (state) {
			case 'synthesizing':
				setUiStatus?.('⚙️  TITS: synthesizing…');
				break;
			case 'playing':
				setUiStatus?.('🔊 TITS: speaking…');
				break;
			case 'idle':
				setUiStatus?.(enabled ? '🔊 TITS: ready' : '🔇 TITS: off');
				break;
		}
	});

	/**
	 * Enqueue `text` for synthesis + playback.
	 * No-op when disabled or text is blank.
	 */
	function speak(text: string, signal?: AbortSignal): void {
		if (!enabled || !text.trim()) return;
		pipeline.enqueue(text, signal);
	}

	// ── Session lifecycle ──────────────────────────────────────────────────────

	pi.on('session_start', async (_event, ctx) => {
		// Wire status updates to this session's ctx
		setUiStatus = (text) => ctx.ui.setStatus(STATUS_KEY, text);

		const theme = ctx.ui.theme;
		const reachable = await checkConnectivity();

		if (!reachable) {
			setUiStatus('🔇 TITS: server unreachable');
			ctx.ui.notify(
				`TITS: Kokoros TTS server not reachable at ${TTS_BASE_URL}`,
				'warning'
			);
			return;
		}

		enabled = true;
		setUiStatus('🔊 TITS: ready');

		// Smoke-test synthesis + playback with a welcome phrase
		speak(
			'Text to speech is online. I will speak responses as they stream in.'
		);

		if (CHUNK_LOGGING) {
			const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
			_dbgLog = path.join(os.tmpdir(), `pi-chunks-${timestamp}.log`);
			chunkIndex = 0;
			appendFileSync(
				_dbgLog,
				`=== pi chunk log — session started ${new Date().toISOString()} ===\n`
			);
			ctx.ui.setStatus('chunk-log', theme.fg('dim', `chunks → ${_dbgLog}`));
		}
	});

	pi.on('session_shutdown', async (_event, ctx) => {
		enabled = false;
		// Null out setUiStatus FIRST so any still-running onState callback
		// (e.g. runPlay's finally block firing after the clip finishes) hits
		// null via optional chaining instead of a now-stale ctx.
		setUiStatus = null;
		pipeline.clear();
		accumulator.reset();
		_dbgLog = null;
		ctx.ui.setStatus(STATUS_KEY, undefined);
		if (CHUNK_LOGGING) ctx.ui.setStatus('chunk-log', undefined);
	});

	// ── Message streaming ──────────────────────────────────────────────────────

	pi.on('message_start', async (event, _ctx) => {
		// Reset the accumulator for each new assistant message turn
		if (event.message.role === 'assistant') {
			accumulator.reset();
		}
	});

	pi.on('message_update', async (event, ctx) => {
		if (!enabled) return;
		// message_update only fires for assistant messages, but guard defensively
		if (event.message.role !== 'assistant') return;

		const ev = event.assistantMessageEvent;

		if (ev.type === 'text_delta') {
			dbgAppend(
				`\n--- chunk ${++chunkIndex} ---\n${JSON.stringify(ev.delta)}\n`
			);
			const sentences = accumulator.feed(ev.delta);
			for (const sentence of sentences) {
				dbgAppend(`\n--- sentence ---\n${JSON.stringify(sentence)}\n`);
				speak(sentence, ctx.signal);
			}
			return;
		}

		// The LLM is transitioning from text to a tool call.  Flush pendingClean
		// immediately — without this, a sentence ending with ":" (or any fragment
		// without a closing boundary) would sit in the accumulator until message_end,
		// which only fires after the entire tool call JSON has streamed through.
		if (ev.type === 'toolcall_start') {
			const remaining = accumulator.flush();
			for (const sentence of remaining) {
				dbgAppend(`\n--- sentence ---\n${JSON.stringify(sentence)}\n`);
				speak(sentence, ctx.signal);
			}
		}
	});

	pi.on('message_end', async (event, ctx) => {
		if (!enabled) return;
		if (event.message.role !== 'assistant') return;

		// Flush any sentence fragment that didn't end with a boundary
		const remaining = accumulator.flush();
		for (const sentence of remaining) {
			dbgAppend(`\n--- sentence ---\n${JSON.stringify(sentence)}\n`);
			speak(sentence, ctx.signal);
		}
	});

	// ── Shortcuts ────────────────────────────────────────────────────────────────

	pi.registerShortcut('alt+s', {
		description: 'Stop TTS playback and clear queue',
		handler: (_ctx) => {
			pipeline.clear();
			setUiStatus?.(enabled ? '🔊 TITS: ready' : '🔇 TITS: off');
		}
	});

	// ── /tits command ──────────────────────────────────────────────────────────

	pi.registerCommand('tits', {
		description: 'Text Input To Speech — /tits [on|off|test|status]',

		getArgumentCompletions: (prefix) => {
			const opts = [
				{ value: 'on', label: 'on', description: 'Enable TTS' },
				{
					value: 'off',
					label: 'off',
					description: 'Disable TTS and clear queue'
				},
				{ value: 'test', label: 'test', description: 'Play a test phrase' },
				{ value: 'status', label: 'status', description: 'Show current status' }
			];
			return opts.filter((o) => o.value.startsWith(prefix));
		},

		handler: async (args, ctx) => {
			const cmd = args.trim().toLowerCase();

			if (cmd === 'off') {
				enabled = false;
				pipeline.clear();
				setUiStatus?.('🔇 TITS: off');
				ctx.ui.notify('TITS: disabled', 'info');
				return;
			}

			if (cmd === 'on') {
				const ok = await checkConnectivity();
				if (!ok) {
					ctx.ui.notify(
						`TITS: server not reachable at ${TTS_BASE_URL}`,
						'error'
					);
					return;
				}
				enabled = true;
				setUiStatus?.('🔊 TITS: ready');
				ctx.ui.notify('TITS: enabled', 'info');
				speak('Text to speech is now enabled.');
				return;
			}

			if (cmd === 'test') {
				const ok = await checkConnectivity();
				if (!ok) {
					ctx.ui.notify(
						`TITS: server not reachable at ${TTS_BASE_URL}`,
						'error'
					);
					return;
				}
				ctx.ui.notify('TITS: playing test phrase…', 'info');
				speak(
					'This is a test of the Text Input To Speech extension for Pi. ' +
						'If you can hear this, the pipeline is working correctly.'
				);
				return;
			}

			// Default / "status"
			const serverOk = await checkConnectivity();
			const lines = [
				'─── TITS status ───────────────────────────────',
				`  enabled : ${enabled}`,
				`  server  : ${serverOk ? '✓ reachable' : '✗ unreachable'} (${TTS_BASE_URL})`,
				`  voice   : ${TTS_VOICE}`,
				`  speed   : ${TTS_SPEED}`,
				`  busy    : ${pipeline.isBusy}`,
				'───────────────────────────────────────────────'
			];
			ctx.ui.notify(lines.join('\n'), 'info');
		}
	});
}
