-- this shows the context of the code block the cursor is in
-- at the top of the screen
return {
	"nvim-treesitter/nvim-treesitter-context",
	lazy = false,
	opts = {
		enable = true,
		min_window_height = 24,
		multiline_threshold = 7,
		-- separator = "",
	}
}
