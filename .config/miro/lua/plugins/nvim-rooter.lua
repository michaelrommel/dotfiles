-- moves to the project's root dir
return {
	"notjedi/nvim-rooter.lua",
	lazy = true,
	event = "BufEnter",
	opt = {
		rooter_patterns = { ".git", "pyproject.toml" }
	}
}
