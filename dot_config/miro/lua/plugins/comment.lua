-- small commeing/uncommenting plugin
return {
	"numToStr/Comment.nvim",
	lazy = true,
	event = "BufEnter",
	opts = {
		mappings = {
			basic = true,
			extra = true,
		},
		ignore = '^$',
	}
}
