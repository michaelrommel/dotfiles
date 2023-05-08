-- some decorative icons used in the statusline and completion menus as well as
-- the tree
return {
	"nvim-tree/nvim-web-devicons",
	lazy = true,
	config = function()
		require("nvim-web-devicons").setup({ default = true })
	end,
}
