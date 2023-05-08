-- zen mode and dimming
return {
	"folke/zen-mode.nvim",
	lazy = true,
	event = "BufEnter",
	dependencies = {
		"folke/twilight.nvim"
	},
	config = function()
		require("zen-mode").setup({
			window = {
				-- width = 0.9,
				width = 120,
			}
		})
	end
}
