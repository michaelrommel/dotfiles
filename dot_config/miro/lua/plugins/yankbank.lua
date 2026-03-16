-- yank manager
return {
	"ptdewey/yankbank-nvim",
	dependencies = {
		"kkharji/sqlite.lua",
		"folke/snacks.nvim",
	},
	cmd = { "YankBank" },
	lazy = false,
	config = function()
		require("yankbank").setup({
			max_entries = 20,
			sep = "-----",
			num_behavior = "jump",
			focus_gain_poll = true,
			persist_type = "sqlite",
			keymaps = {
				paste = "<CR>",
				paste_back = "P",
			},
			registers = {
				yank_register = "+",
			},
			bind_indices = "<leader>p",
			pickers = {
				snacks = true,
			},
		})
	end,
}
