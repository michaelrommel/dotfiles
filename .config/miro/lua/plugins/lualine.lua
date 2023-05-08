-- bare necessities statusline in vim, shows git status, filetype, encoding
-- and cursor position without much configuration
return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	config = function()
		require("lualine").setup({
			options = {
				theme = 'gruvbox',
			},
			sections = {
				lualine_y = { "progress", "selectioncount" }
			}
		})
	end,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"ellisonleao/gruvbox.nvim",
	}
}
