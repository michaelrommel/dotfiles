return {
	"robitx/gp.nvim",
	config = function()
		local conf = {
			providers = {
				ollama = {
					disable = false,
					endpoint = "http://192.168.13.195:11434/v1/chat/completions",
					secret = "Dummy Secret",
				},
				openai = {
					disable = true,
				},
			},
			agents = {
				{
					provider = "ollama",
					name = "ChatOllama",
					chat = true,
					command = false,
					-- string with model name or table with model name and parameters
					model = {
						model = "qwen3:14b",
						temperature = 0.6,
						top_p = 1,
						min_p = 0.05,
					},
					-- system prompt (use this to specify the persona/role of the AI)
					system_prompt = "You are a general AI assistant.",
				},
				{
					provider = "ollama",
					name = "CodeOllama",
					chat = false,
					command = true,
					-- string with model name or table with model name and parameters
					model = {
						model = "qwen3:14b",
						temperature = 0.4,
						top_p = 1,
						min_p = 0.05,
					},
					-- system prompt (use this to specify the persona/role of the AI)
					system_prompt = require("gp.defaults").code_system_prompt,
				},
			},
			whisper = {
				disable = true,
			},
			image = {
				disable = true,
			},
		}
		require("gp").setup(conf)
		-- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
	end,
}
