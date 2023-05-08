-- offers a "help" function for key mappings
return {
	"folke/which-key.nvim",
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("which-key").setup({
			window = { border = "rounded" },
		})
		require("core.mappings").std_mappings()
	end,
}
