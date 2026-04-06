/**
 * Tokens Per Second Extension (tokens/second)
 *
 * Displays the current streaming rate (tokens/second) once a stream starts producing
 * tokens, and continues showing it until the stream finishes.
 *
 * Usage:
 *   pi -e ./tokens-per-second.ts
 */

import type { AssistantMessageEvent } from '@mariozechner/pi-ai';
import type {
	ExtensionAPI,
	ExtensionContext
} from '@mariozechner/pi-coding-agent';

export default function (pi: ExtensionAPI) {
	let tokenCount = 0;
	let charCount = 0;
	let startTime: number | null = null;
	let lastUpdateTokens = 0;
	let lastUpdate: number | null = null;
	let currentTokensPerSecond: number | null = null;
	let isActive = false;

	function reset() {
		tokenCount = 0;
		charCount = 0;
		startTime = null;
		lastUpdateTokens = 0;
		lastUpdate = null;
		currentTokensPerSecond = null;
		isActive = false;
	}

	function updateRate(ctx: ExtensionContext) {
		if (startTime === null || lastUpdate === null) return;

		const now = Date.now();
		const elapsed = now - startTime;
		// Only update rate if we've waited at least 500ms to avoid showing 0 or unstable rates
		if (elapsed < 500) return;

		const tokensPerSecond = tokenCount > 0 ? (tokenCount / elapsed) * 1000 : 0;
		currentTokensPerSecond = tokensPerSecond;

		// Update the status bar with the current rate
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
		tokenCount = 0;
		startTime = Date.now();
		lastUpdateTokens = 0;
		lastUpdate = startTime;
		currentTokensPerSecond = null;
		isActive = true;
		updateRate(ctx);
	}

	function stopTracking(ctx: ExtensionContext, counter) {
		if (isActive) {
			// Show the final rate one last time
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
			setTimeout(() => {
				ctx.ui.setStatus('tokens-s', theme.fg('dim', rateText));
			}, 30000);
		}
		reset();
	}

	// initialize ui
	pi.on('session_start', async (event, ctx) => {
		const theme = ctx.ui.theme;
		ctx.ui.setStatus('tokens-s', theme.fg('dim', '<TokenRate>'));
	});

	// Track when streaming starts
	pi.on('message_start', async (event, ctx) => {
		if (event.message.role === 'assistant') {
			startTracking(ctx);
		}
	});

	// Update token rate as tokens stream in
	pi.on('message_update', async (event, ctx) => {
		if (!isActive) return;

		// const util = require('util');
		// console.log(util.inspect(event, { depth: null }));

		const eventObj = event.assistantMessageEvent;
		if (
			eventObj?.type === 'text_delta' ||
			eventObj?.type === 'thinking_delta'
		) {
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
		// Also handle function_call_start for completeness
		if (eventObj?.type === 'function_call_start') {
			// Optionally count function calls if needed
		}
	});

	// Stop tracking when message ends
	pi.on('message_end', async (event, ctx) => {
		if (event.message.role === 'assistant') {
			// const util = require('util');
			// console.log(util.inspect(event, { depth: null }));
			stopTracking(ctx, event.message.usage.output);
		}
	});

	// Also reset at turn boundaries
	pi.on('turn_start', async (_event, ctx) => {
		// Reset for new turn
		reset();
	});

	// Cleanup on shutdown
	pi.on('session_shutdown', async (_event, ctx) => {
		reset();
	});
}
