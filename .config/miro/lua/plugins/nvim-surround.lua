-- keybindings for changing surround quotes, brackets etc.
return {
	"kylechui/nvim-surround",
	lazy = true,
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
			-- Configuration here, or leave empty to use defaults
		})
	end
}
