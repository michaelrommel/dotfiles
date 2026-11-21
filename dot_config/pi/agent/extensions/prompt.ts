import type { AssistantMessageEvent } from '@mariozechner/pi-ai';
import type { ExtensionAPI } from '@mariozechner/pi-coding-agent';

export default function (pi: ExtensionAPI) {
	pi.on('before_agent_start', async (event) => {
		return {
			// Append something every turn
			systemPrompt:
				'Your name is Claudia. ' +
				event.systemPrompt +
				'\nNever use the following character "—" anywhere in code or code comments! You can use box drawing characters in markdown documents.' +
				'\nWhen you encounter box drawing characters in code comments, replace them by minus signs or remove them on the next edit.' +
				'\nFor more complicated edits, you have python available.' +
				'\nIt is forbidden to run a find command on / over the whole filesystem, which would take hours.'
		};
	});
}
