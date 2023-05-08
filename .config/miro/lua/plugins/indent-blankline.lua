-- visually draws vertical lines for code blocks
return {
	"lukas-reineke/indent-blankline.nvim",
	lazy = true,
	event = "BufEnter",
	config = function()
		require("indent_blankline").setup {
			show_current_context = true,
			show_current_context_start = false,
		}
	end
}
