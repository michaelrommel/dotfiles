-- explorer style tree on the left
return {
	"nvim-tree/nvim-tree.lua",
	lazy = true,
	version = "*",
	event = "BufEnter",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			view = {
				width = 50,
				mappings = {
					list = {
					}
				}
			},
			update_cwd = true,
			update_focused_file = {
				enable = true,
				update_cwd = true,
			},
		})
	end,
}