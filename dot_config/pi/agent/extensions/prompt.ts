import type { AssistantMessageEvent } from '@mariozechner/pi-ai';
import type { ExtensionAPI } from '@mariozechner/pi-coding-agent';

export default function (pi: ExtensionAPI) {
	pi.on('before_agent_start', async (event) => {
		return {
			// Append something every turn
			systemPrompt: 'Your name is Claudia. ' + event.systemPrompt
		};
	});
}
