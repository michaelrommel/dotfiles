-- dim inactive code blocks
return {
	"folke/twilight.nvim",
	lazy = true,
	event = "BufEnter",
	opt = {
		dimming = {
			alpha = 0.7,
		}
	}
}
