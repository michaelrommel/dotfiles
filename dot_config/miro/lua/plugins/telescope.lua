-- fuzzy file finder
return {
	"nvim-telescope/telescope.nvim",
	lazy = true,
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-fzf-native.nvim",
	},
	config = function()
		require("telescope").setup({
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				}
			},
			defaults = {
				mappings = {
					n = {
						["q"] = require('telescope.actions').close,
					},
				},
			},
		})
		require("telescope").load_extension('fzf')
	end,
}
