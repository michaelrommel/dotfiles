-- this extends treesitter to know about a language's
-- structure for text objects
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	lazy = true,
	opts = {
		select = {
			enable = true,
			lookahead = true,
		}
	}
}
