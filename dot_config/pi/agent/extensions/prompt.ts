import type { AssistantMessageEvent } from '@mariozechner/pi-ai';
import type { ExtensionAPI } from '@mariozechner/pi-coding-agent';

export default function (pi: ExtensionAPI) {
	pi.on('before_agent_start', async (event) => {
		return {
			// Append something every turn
			systemPrompt:
				'Your name is Gwen. ' +
				event.systemPrompt +
				'\nFor more complicated edits, you have python available.' +
				'\nWhen being asked for code review, use the "Hunk" skill to perform the review.' +
				'\n[CRITICAL INDENTATION PROTOCOL]' +
				'\n- ALL code outputs, edits, and search patterns MUST use literal tabs (\t), NEVER spaces.' +
				'\n- Indentation depth MUST match the source file exactly using 1 tab per level.' +
				'\n- You are FORBIDDEN from using space-based regex or literal space characters for code alignment.'
		};
	});
}
