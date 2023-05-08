-- visually draws vertical lines for code blocks
return {
	"lukas-reineke/indent-blankline.nvim",
	lazy = true,
	event = "BufEnter",
	opts = {
		show_current_context = true,
		show_current_context_start = false,
	}
}
