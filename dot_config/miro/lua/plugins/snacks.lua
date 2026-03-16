return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		input = {
			enabled = true,
			win = {
				keys = {
					i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
				},
			},
		},
		picker = {
			enabled = true,
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
					},
				},
			},
		},
		bigfile = { enabled = true },
		quickfile = { enabled = true },

		dashboard = { enabled = false },
		explorer = { enabled = false },
		indent = { enabled = false },
		notifier = { enabled = false },
		scope = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
	},
}
