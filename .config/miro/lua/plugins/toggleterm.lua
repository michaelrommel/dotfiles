-- terminal buffer, that can be resumed
return {
	"akinsho/toggleterm.nvim",
	lazy = true,
	version = "*",
	cmd = "ToggleTerm",
	dependencies = {
	},
	config = function()
		local default_opts = require("configs.conf_toggleterm").default_opts
		require("toggleterm").setup(default_opts)
	end,
}
