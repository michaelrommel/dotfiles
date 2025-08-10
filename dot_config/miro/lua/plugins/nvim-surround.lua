-- keybindings for changing surround quotes, brackets etc.
return {
	"kylechui/nvim-surround",
	lazy = true,
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	opts = {
		keymaps = {
			insert = "<C-g>s",
			insert_line = "<C-g>S",
			normal = "ys",
			normal_cur = false,
			normal_line = "yS",
			normal_cur_line = false,
			visual = "S",
			visual_line = "gS",
			delete = "ds",
			change = "cs",
			change_line = "cS",
		}
	}
}
