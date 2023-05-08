-- highlight TODO and other comments
return {
	"folke/todo-comments.nvim",
	lazy = true,
	event = "BufEnter",
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	config = function()
		require("todo-comments").setup()
	end
}
