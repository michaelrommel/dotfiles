# TITS — Text Input To Speech

A [pi-coding-agent](https://github.com/earendil-works/pi) extension that reads
LLM responses aloud in real time using a local
[Kokoros](https://github.com/lucasjinreal/Kokoros) TTS server.

---

## Prerequisites

### Kokoros OpenAI-compatible server

Build and start kokoros with two parallel synthesis instances:

```bash
# in the Kokoros repo
cargo build --release
./target/release/koko openai --instances 2 --port 3600
```

Two instances match `MAX_CONCURRENT = 2` in the extension, allowing one
sentence to be synthesised while the previous one is still playing.

### Audio player

| Platform | Player | Install |
|----------|--------|---------|
| macOS    | `afplay` | built-in |
| Linux    | `aplay`  | `apt install alsa-utils` |

---

## Installation

The extension lives in:

```
~/.pi/agent/extensions/tits/index.ts
```

It is symlinked from the development tree:

```
~/.pi/agent/extensions/tits → /path/to/pi/extensions/tits
```

No npm dependencies — only Node.js built-ins and the globally-installed
`@earendil-works/pi-coding-agent` package.

---

## Configuration

All tuneable constants are at the top of `index.ts`:

| Constant | Default | Description |
|----------|---------|-------------|
| `TTS_BASE_URL` | `http://localhost:3600` | Kokoros server URL |
| `TTS_VOICE` | `bf_lily.4+bf_emma.6` | Voice (supports blending) |
| `TTS_SPEED` | `1.3` | Speech rate (1.0 = normal) |
| `MAX_CONCURRENT` | `2` | Parallel synthesis requests |
| `MIN_SENTENCE_WORDS` | `5` | Minimum words to synthesise |

---

## Commands

| Command | Description |
|---------|-------------|
| `/tits` | Show current status |
| `/tits on` | Enable TTS (re-checks server) |
| `/tits off` | Disable TTS and clear queue |
| `/tits test` | Play a test phrase |

## Keyboard shortcut

| Key | Action |
|-----|--------|
| `alt+s` | Stop current playback and clear queue |

Works in both insert and normal mode of a vim-style modal editor.

---

## Architecture

```
message_update  (text_delta events only)
  └─► TextAccumulator
        ├─ rawBuffer       — every character received, verbatim
        ├─ isInsideIncompleteCodeBlock() — gates processing while inside ```
        ├─ filterForTTS()  — strips markdown artefacts from clean regions
        ├─ pendingClean    — filtered text waiting for a sentence boundary
        ├─ startsNewListItem() — stateful cross-chunk list boundary detector
        └─ extractSentences()  — boundary regex [.!?:]+ \s+ [A-Z`"']
              │
              ▼  (on toolcall_start, code block entry, or message_end: flush)
          TTSPipeline
            ├─ orderedQueue   — Promise<WAV>[] in submission order
            ├─ waitQueue      — overflow when both instances busy
            ├─ startSynthesis()  — POST /v1/audio/speech → WAV bytes
            └─ runPlay()         — awaits orderedQueue front-to-back
                                   → writes temp WAV → afplay/aplay
                                   → deletes temp file
```

### Parallel synthesis, ordered playback

Up to `MAX_CONCURRENT` (2) HTTP synthesis requests run simultaneously.
`runPlay()` consumes `orderedQueue` strictly in submission order — if
sentence 1 finishes synthesising before sentence 0, it waits. Once sentence
0 starts playing, sentence 1 is already synthesised and plays immediately
after with no gap.

### Text filtering (`filterForTTS`)

Applied to each newly-scanned chunk of raw text. Steps in order:

1. **Complete fenced code blocks** — ` ``` ` and `~~~`, but only when the
   fence marker appears at the **start of a line** (≤3 spaces of indent,
   CommonMark rule). This prevents `` ` ``` ` `` inside inline code spans
   (e.g. in table cells) from being mistaken for a real fence and causing
   large chunks of content to pile up unsplit.
2. **Inline code** — single-word spans (no whitespace) kept as-is
   (e.g. `sox`, `null`, `git`); multi-word spans removed entirely.
3. Markdown images — removed
4. Markdown links — label kept, URL removed
5. Bare URLs — removed
6. ATX headers (`#`, `##`, …) — removed
7. **List item separator** — `\n- item` → `. Item` (or ` Item` if the
   preceding line already ends with punctuation), capitalising the first
   character so the sentence boundary detector splits between items. Runs
   **before** bold/italic stripping so `*` bullets are still present.
   Handles unordered (`-`, `*`, `+`) and ordered (`1.`, `2.`, …) markers.
   First character matched with `(\S)` (not `(\w)`) so backtick-starting
   items like `` `alt+s` `` are covered.
8. **Bold markers** (`**`, `__`) — deleted outright (not paired capture),
   chunk-boundary-safe.
9. **Italic markers** (`*`, `_`) — deleted outright.
10. Horizontal rules — removed
11. Blockquotes (`>`) — removed
12. List item prefixes — remaining markers stripped
13. Newlines collapsed to spaces; runs of spaces collapsed to one.
    **No `.trim()`** — natural token spacing preserved so sub-word tokens
    (`"cancel"` + `"lable"`) concatenate as `"cancellable"` rather than
    `"cancel lable"`.

### Sentence boundary detection

```
/[.!?:]+\s+(?=[A-Z\u2018\u201C"'`])/g
```

- `.!?` — standard sentence endings
- `:` — colon so introductory phrases before code blocks or lists are
  spoken without waiting for the next sentence
- `` ` `` — backtick so list items starting with inline code spans
  (e.g. `` `alt+s` shortcut… ``) are split correctly
- Capital-letter / opening-quote / backtick lookahead — avoids false
  splits on `Dr. Smith`, `e.g. this`, `10:30 am`

### List item sentence breaks (cross-chunk)

`filterForTTS` step 7 handles list boundaries that arrive in **one chunk**
(`\S\n- word` all present). In streaming the LLM often sends `"remainder\n"`
as one token and `"- Next item"` as the next, so step 7 never sees them
together. `TextAccumulator.startsNewListItem()` handles this statelessly:

- **Case B1** — `rawBuffer[lastScanPos - 1] === '\n'` and the new chunk
  starts with a list marker: classic one-token-per-line split.
- **Case B2** — the new chunk itself starts with `\n` followed by a list
  marker but has no `\S` before the `\n`, so step 7's `(\S)\n` pattern
  can't fire.

### Flush triggers

Text stuck in `pendingClean` is flushed to the pipeline immediately on:

| Trigger | Reason |
|---------|--------|
| `toolcall_start` event | LLM transitions from text to a tool call — `message_end` would not fire until the full tool call JSON streams through |
| Code block entry (`isInsideIncompleteCodeBlock` flips to true) | Intro sentence before ` ``` ` (often ending with `:`) would otherwise wait for the block to close |
| `message_end` event | End of assistant turn — catches any remaining fragment |

---

## Lifecycle events hooked

| Event | Action |
|-------|--------|
| `session_start` | Connectivity check → welcome phrase → footer status |
| `session_shutdown` | Clear pipeline, reset accumulator, clear footer |
| `message_start` | Reset accumulator for new assistant message |
| `message_update` | Feed `text_delta`; flush on `toolcall_start` |
| `message_end` | Flush accumulator remainder |

---

## Footer status

| Status | Meaning |
|--------|---------|
| `🔊 TITS: ready` | Server reachable, waiting |
| `⚙️  TITS: synthesizing…` | HTTP request in flight |
| `🔊 TITS: speaking…` | Audio playing |
| `🔇 TITS: off` | Disabled via `/tits off` |
| `🔇 TITS: server unreachable` | Kokoros not responding |

---

## Known open issues

| # | Issue | Notes |
|---|-------|-------|
| 1 | `clear()` doesn't cancel in-flight synthesis requests | In-flight HTTP fetches run to completion; results are dropped silently. Fix: store an `AbortController` per `startSynthesis()` call and abort them in `clear()`. |
| 2 | Currently-playing audio cannot be interrupted | `afplay` runs to the end of the current sentence after `clear()`. Fix: store the `ChildProcess` reference in `playWav()` and call `.kill()` from `clear()`. |
| 3 | `_` stripping is overly broad | All underscores deleted, so `RUST_LOG` becomes `RUSTLOG`. Fix: only strip `_` when it's clearly an emphasis marker (`_text_` pattern), not inside identifiers. |
| 4 | Table content not filtered | Markdown table row separators (`\|`) pass through `filterForTTS` and appear in synthesis input. Fix: strip `\|` separators and table header/divider rows. |
| 5 | Welcome phrase plays on every session switch | Plays on `/new`, `/resume`, and `/fork` as well as startup. Fix: gate on `event.reason === "startup"` in `session_start`. |
| 6 | No runtime voice/speed controls | `TTS_VOICE` and `TTS_SPEED` are compile-time constants. Fix: add `/tits voice <name>` and `/tits speed <n>` sub-commands. |
