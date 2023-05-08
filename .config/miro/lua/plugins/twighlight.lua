-- dim inactive code blocks
return {
	"folke/twilight.nvim",
	lazy = true,
	event = "BufEnter",
	config = function()
		require("twilight").setup({
			dimming = {
				alpha = 0.7,
			}
		})
	end
}
