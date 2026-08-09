/**
 * Tokens Per Second + Prompt Progress Extension
 *
 * - Injects `return_progress: true` and `timings_per_token: true` into every
 *   provider request (llama.cpp will use them; other providers ignore unknown fields).
 * - For llama.cpp providers: polls `/slots` during prompt processing to show
 *   progress percentage, token count, and ETA.
 * - Displays generation rate (tokens/second) based on token arrival times.
 *
 * Usage:
 *   pi -e ./tokens-per-second.ts
 */

import type {
	ExtensionAPI,
	ExtensionContext
} from '@mariozechner/pi-coding-agent';

const LLAMA_CPP_PROVIDER = 'llama.cpp';
const SLOTS_POLL_INTERVAL_MS = 5000;

export default function (pi: ExtensionAPI) {
	// --- Prompt progress state (llama.cpp only) ---
	let slotsPollTimer: ReturnType<typeof setInterval> | null = null;
	let slotsBaseUrl: string | null = null;
	let slotsAuthHeaders: Record<string, string> | null = null;
	let promptTotalTokens = 0;
	let promptCachedTokens = 0;
	let promptStartMs: number | null = null;

	// --- Token rate state ---
	let tokenCount = 0;
	let charCount = 0;
	let startTime: number | null = null;
	let lastUpdateTokens = 0;
	let lastUpdate: number | null = null;
	let currentTokensPerSecond: number | null = null;
	let isActive = false;

	function reset() {
		stopSlotsPolling();
		slotsBaseUrl = null;
		slotsAuthHeaders = null;
		promptTotalTokens = 0;
		promptCachedTokens = 0;
		promptStartMs = null;

		tokenCount = 0;
		charCount = 0;
		startTime = null;
		lastUpdateTokens = 0;
		lastUpdate = null;
		currentTokensPerSecond = null;
		isActive = false;
	}

	// --- Slots polling (llama.cpp prompt progress) ---

	function stopSlotsPolling() {
		if (slotsPollTimer) {
			clearInterval(slotsPollTimer);
			slotsPollTimer = null;
		}
	}

	async function pollSlots(ctx: ExtensionContext) {
		if (!slotsBaseUrl || !slotsAuthHeaders) return;

		try {
			const res = await fetch(slotsBaseUrl + '/slots', {
				headers: slotsAuthHeaders
			});
			if (!res.ok) return;

			const slots: any[] = await res.json();
			if (!slots || slots.length === 0) return;

			// Find the slot that is processing a prompt
			const processingSlot = slots.find(
				(s: any) =>
					s.is_processing &&
					s.n_prompt_tokens != null &&
					s.n_prompt_tokens_processed != null &&
					s.n_prompt_tokens_processed < s.n_prompt_tokens
			);

			if (!processingSlot) {
				// No slot is processing — prompt is done (or never started)
				stopSlotsPolling();
				return;
			}

			promptTotalTokens = processingSlot.n_prompt_tokens;
			promptCachedTokens = processingSlot.n_prompt_tokens_cache ?? 0;
			const processed = processingSlot.n_prompt_tokens_processed;

			const uncachedTotal = promptTotalTokens - promptCachedTokens;
			const uncachedProcessed = Math.max(0, processed - promptCachedTokens);
			const progressFraction =
				uncachedTotal > 0 ? uncachedProcessed / uncachedTotal : 0;
			const clampedProgress = Math.min(1, Math.max(0, progressFraction));

			const now = Date.now();
			const elapsed = promptStartMs ? now - promptStartMs : 0;

			// ETA calculation
			let etaStr = '';
			if (clampedProgress > 0.01 && clampedProgress < 1 && elapsed > 1000) {
				const totalMs = elapsed / clampedProgress;
				const remainingMs = totalMs - elapsed;
				if (remainingMs < 3000) {
					etaStr = '<3s';
				} else if (remainingMs < 60000) {
					etaStr = Math.round(remainingMs / 1000) + 's';
				} else {
					const mins = Math.floor(remainingMs / 60000);
					const secs = Math.round((remainingMs % 60000) / 1000);
					etaStr = mins + 'm' + (secs > 0 ? secs + 's' : '');
				}
			}

			const theme = ctx.ui.theme;
			const pct = Math.round(clampedProgress * 100);
			const parts: string[] = [theme.fg('accent', `⏳ ${pct}%`)];
			if (etaStr) parts.push(theme.fg('dim', etaStr));
			parts.push(theme.fg('dim', `${processed}/${promptTotalTokens}`));
			ctx.ui.setStatus('tokens-s', parts.join(' '));
		} catch {
			// Network error — keep polling, will retry
		}
	}

	function startSlotsPolling(ctx: ExtensionContext) {
		stopSlotsPolling();
		promptStartMs = Date.now();
		slotsPollTimer = setInterval(() => pollSlots(ctx), SLOTS_POLL_INTERVAL_MS);
		// Do an immediate poll
		pollSlots(ctx);
	}

	// --- Token rate ---

	function updateRate(ctx: ExtensionContext) {
		if (startTime === null || lastUpdate === null) return;

		const now = Date.now();
		const elapsed = now - startTime;
		if (elapsed < 500) return;

		const tokensPerSecond = tokenCount > 0 ? (tokenCount / elapsed) * 1000 : 0;
		currentTokensPerSecond = tokensPerSecond;

		const theme = ctx.ui.theme;
		const rateText =
			tokensPerSecond > 0
				? theme.fg('accent', `${tokensPerSecond.toFixed(1)}t/s (${tokenCount})`)
				: '';

		if (rateText != '') {
			ctx.ui.setStatus('tokens-s', rateText);
		}
	}

	function startTracking(ctx: ExtensionContext) {
		// Generation has started — stop prompt progress polling
		stopSlotsPolling();

		tokenCount = 0;
		startTime = Date.now();
		lastUpdateTokens = 0;
		lastUpdate = startTime;
		currentTokensPerSecond = null;
		isActive = true;
		updateRate(ctx);
	}

	function stopTracking(ctx: ExtensionContext, counter: number) {
		if (isActive) {
			const theme = ctx.ui.theme;
			const estimated = tokenCount;
			tokenCount = counter;
			updateRate(ctx);
			const rateText =
				currentTokensPerSecond !== null && currentTokensPerSecond > 0
					? `${currentTokensPerSecond.toFixed(1)}t/s (${tokenCount} tokens [${estimated}])`
					: '';
			if (rateText != '') {
				ctx.ui.setStatus('tokens-s', theme.fg('success', rateText));
			}
		}
		reset();
	}

	// --- Check if current model is llama.cpp ---

	function isLlamaCpp(ctx: ExtensionContext): boolean {
		return ctx.model?.provider === LLAMA_CPP_PROVIDER;
	}

	// --- Inject llama.cpp-specific params into every request ---
	pi.on('before_provider_request', (event, _ctx) => {
		return {
			...event.payload,
			return_progress: true,
			timings_per_token: true
		};
	});

	// --- Initialize UI ---
	pi.on('session_start', async (_event, ctx) => {
		const theme = ctx.ui.theme;
		ctx.ui.setStatus('tokens-s', theme.fg('dim', '<TokenRate>'));
	});

	// --- Start tracking + prompt progress polling when assistant message begins ---
	pi.on('message_start', async (event, ctx) => {
		if (event.message.role !== 'assistant') return;

		// Always start token tracking (works for all providers)
		startTracking(ctx);

		// Start slots polling for llama.cpp only (prompt progress)
		if (!isLlamaCpp(ctx)) return;

		try {
			const model = ctx.model;
			if (model && model.baseUrl) {
				const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
				if (auth.ok) {
					slotsBaseUrl = model.baseUrl.replace(/\/+$/, '');
					slotsAuthHeaders = { ...(auth.headers ?? {}) };
					if (auth.apiKey && !slotsAuthHeaders['Authorization']) {
						slotsAuthHeaders['Authorization'] = 'Bearer ' + auth.apiKey;
					}
					startSlotsPolling(ctx);
				}
			}
		} catch (e) {
			// Non-fatal: slots polling won't work, but token rate still does
			console.error('[tokens-per-second] slots polling setup failed:', e);
		}
	});

	// --- Update token rate as tokens stream in ---
	pi.on('message_update', async (event, ctx) => {
		if (!isActive) return;

		const eventObj = event.assistantMessageEvent;
		if (
			eventObj?.type === 'text_delta' ||
			eventObj?.type === 'thinking_delta'
		) {
			// Generation started — stop prompt progress polling
			stopSlotsPolling();

			charCount += eventObj.delta.length;
			tokenCount = charCount / 4;
			let lut = Math.floor(tokenCount / 40);
			if (
				(lut > lastUpdateTokens ||
					(lastUpdate !== null && Date.now() - lastUpdate > 750)) &&
				Date.now() - startTime > 200
			) {
				updateRate(ctx);
				lastUpdate = Date.now();
				lastUpdateTokens = lut;
			}
		}
	});

	// --- Stop tracking when message ends ---
	pi.on('message_end', async (event, ctx) => {
		if (event.message.role === 'assistant') {
			stopTracking(ctx, event.message.usage.output);
		}
	});

	// --- Reset at turn boundaries ---
	pi.on('turn_start', async (_event, ctx) => {
		reset();
	});

	// --- Cleanup on shutdown ---
	pi.on('session_shutdown', async (_event, ctx) => {
		reset();
	});
}
