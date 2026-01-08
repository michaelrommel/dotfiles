return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/mcphub.nvim",
	},
	config = function()
		local providers = require("codecompanion.providers")
		require("codecompanion").setup({
			opts = {
				log_level = "TRACE", -- or "TRACE"
			},
			display = {
				diff = {
					enabled = true,
					provider = providers.inline,
				},
			},
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
					opts = {
						make_vars = true,
						make_slash_commands = true,
						show_result_in_chat = true,
					},
				},
			},
			interactions = {
				chat = {
					adapter = {
						name = "ollama",
						model = "ministral-3:14b",
						-- model = "qwen3:14b",
					},
				},
				inline = {
					adapter = {
						name = "ollama",
						model = "ministral-3:14b",
						-- model = "qwen3:14b",
					},
				},
				cmd = {
					adapter = {
						name = "ollama",
						model = "ministral-3:14b",
						-- model = "qwen3:14b",
					},
				},
				background = {
					adapter = {
						name = "ollama",
						model = "ministral-3:14b",
						-- model = "qwen3:14b",
					},
				},
			},
			adapters = {
				http = {
					ollama = function()
						return require("codecompanion.adapters").extend("ollama", {
							env = {
								url = "http://192.168.13.195:11434",
								-- api_key = "OLLAMA_API_KEY",
							},
							headers = {
								["Content-Type"] = "application/json",
								-- ["Authorization"] = "Bearer ${api_key}",
							},
							parameters = {
								sync = true,
							},
						})
					end,
				},
			},
		})
	end,
}
