-- moves to the project's root dir
return {
	"notjedi/nvim-rooter.lua",
	lazy = true,
	event = "BufEnter",
	config = function()
		require("nvim-rooter").setup({
			rooter_patterns = { ".git", "pyproject.toml" }
		})
	end
}
