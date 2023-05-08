-- an implementation of the Debug Adapter Protocol for nvim
return {
	"mfussenegger/nvim-dap",
	lazy = true,
	ft = { "python", "javascript" },
	config = function()
		-- register key mappings for working in debug mode
		require("core.mappings").dap_mappings()
		-- set up the javascript adapter, the nvim-dap-vscode-js does not work
		require("configs.conf_dap_js").setup()
	end,
	dependencies = {
		"jay-babu/mason-nvim-dap.nvim",
		-- this configures the python adapter
		-- make sure that in the top level directory there is alqays
		-- a pyproject.toml file with settings for venv and pyright
		{
			"mfussenegger/nvim-dap-python",
			lazy = true,
			config = function()
				-- require("dap-python").setup('/Volumes/Samsung/Software/michael/rock_paper_scissors/venv/bin/python')	
				require("dap-python").setup()
			end
		},
		-- a TUI interface for the debug adapter
		{
			"rcarriga/nvim-dap-ui",
			lazy = true,
			config = function()
				require("dapui").setup()
			end
		},

	}
}
