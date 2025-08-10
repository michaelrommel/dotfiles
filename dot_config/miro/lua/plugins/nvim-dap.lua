-- an implementation of the Debug Adapter Protocol for nvim
return {
	"mfussenegger/nvim-dap",
	lazy = true,
	ft = { "python", "javascript", "rust" },
	dependencies = {
		"jay-babu/mason-nvim-dap.nvim",
		"mfussenegger/nvim-dap-python",
		"rcarriga/nvim-dap-ui",
	},
	config = function()
		-- register key mappings for working in debug mode
		require("core.mappings").dap_mappings()
		-- set up the javascript adapter, the nvim-dap-vscode-js does not work
		require("configs.conf_dap_js").setup()
		-- set up the rust adapter
		require("configs.conf_dap_rust").setup()
	end,
}
