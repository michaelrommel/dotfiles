-- small commeing/uncommenting plugin
return {
	"numToStr/Comment.nvim",
	lazy = true,
	event = "BufEnter",
	config = function()
		require('Comment').setup()
	end
}
