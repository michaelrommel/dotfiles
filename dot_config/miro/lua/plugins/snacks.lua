return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = false,
			doc = {
				inline = false,
				float = true,
			},
			resolve = function(file, src)
				return file .. "../../../.." .. src
			end
		},
		picker = { enabled = true },
		bigfile = { enabled = true },
		indent = {
			indent = {
				enabled = false,
				priority = 1,
				char = "▏", -- U+258f
			},
			scope = {
				enabled = false,
				priority = 200,
				char = "▎", -- U+258e
				underline = false,
				only_current = false,
			},
			animate = {
				duration = {
					total = 150
				}
			}
		}
	}
}
