// ~/.pi/agent/extensions/debug-logger.js
export default function (pi) {
	pi.on('before_provider_request', async (event, ctx) => {
		try {
			const fs = require('fs');
			const path = require('path');
			const util = require('util');
			
			// Create logs directory if it doesn't exist
			const homeDir = require('os').homedir();
			const logDir = `${homeDir}/.local/share/pi/logs`;
			if (!fs.existsSync(logDir)) {
				fs.mkdirSync(logDir, { recursive: true });
			}
			
			// Create timestamped log file for requests
			const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
			const logFile = `${logDir}/model-requests-${timestamp}.txt`;
			
			// Format the request content for logging
			const requestContent = util.inspect(event.payload, { depth: null });
			fs.appendFileSync(logFile, `\n\n\n\n=== MODEL REQUEST (Logged at ${timestamp}) ===` + '\n' + requestContent + '\n=== END REQUEST ===\n');

			// Keep only last 20 log files for requests
			const LOG_FILE_PATTERN = /^model-requests-.*\.txt$/;
			const MAX_LOG_FILES = 20;
			try {
				const existingFiles = fs.readdirSync(logDir)
					.filter(file => LOG_FILE_PATTERN.test(file))
					.sort((a, b) => {
						const aStat = fs.statSync(path.join(logDir, a));
						const bStat = fs.statSync(path.join(logDir, b));
						return bStat.mtimeMs - aStat.mtimeMs; // Newest first
					});
				for (let i = MAX_LOG_FILES; i < existingFiles.length; i++) {
					fs.unlinkSync(path.join(logDir, existingFiles[i]));
				}
			} catch (err) {
				// Ignore errors during cleanup
			}
		} catch (err) {
			console.error('[debug-logger] Request logging error:', err.message);
		}
	});

	pi.on('message_end', async (event, ctx) => {
		try {
			if (event.message.role === 'assistant') {
				const fs = require('fs');
				const path = require('path');
				const util = require('util');
				
				// Create logs directory if it doesn't exist
				const homeDir = require('os').homedir();
				const logDir = `${homeDir}/.local/share/pi/logs`;
				if (!fs.existsSync(logDir)) {
					fs.mkdirSync(logDir, { recursive: true });
				}
				
				// Create timestamped log file for responses
				const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
				const logFile = `${logDir}/model-responses-${timestamp}.txt`;
				
				// Format the response content for logging
				const responseContent = util.inspect(event.message, { depth: null });
				fs.appendFileSync(logFile, `\n\n\n\n=== MODEL RESPONSE (Logged at ${timestamp}) ===` + '\n' + responseContent + '\n=== END RESPONSE ===\n');

				// Keep only last 20 log files for responses
				const LOG_FILE_PATTERN = /^model-responses-.*\.txt$/;
				const MAX_LOG_FILES = 20;
				try {
					const existingFiles = fs.readdirSync(logDir)
						.filter(file => LOG_FILE_PATTERN.test(file))
						.sort((a, b) => {
							const aStat = fs.statSync(path.join(logDir, a));
							const bStat = fs.statSync(path.join(logDir, b));
							return bStat.mtimeMs - aStat.mtimeMs; // Newest first
						});
					for (let i = MAX_LOG_FILES; i < existingFiles.length; i++) {
						fs.unlinkSync(path.join(logDir, existingFiles[i]));
					}
				} catch (err) {
					// Ignore errors during cleanup
				}
			}
		} catch (err) {
			console.error('[debug-logger] Response logging error:', err.message);
		}
	});
}
