-- highlight TODO and other comments
return {
	"folke/todo-comments.nvim",
	lazy = true,
	event = "BufEnter",
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	config = true,
	-- FIXME: there is some work for you
	-- BUG: this should be corrected
	-- HACK: investigate this
	-- WARN: this will probably break later
	-- PERF: this is so slow
	-- TEST: something to be covered in a test
	-- TODO: maybe feature it in documentation
	-- NOTE: future me will thank me
}
