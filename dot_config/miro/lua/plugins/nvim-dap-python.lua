return {
	-- this configures the python adapter
	-- make sure that in the top level directory there is alqays
	-- a pyproject.toml file with settings for venv and pyright
	"mfussenegger/nvim-dap-python",
	lazy = true,
	config = function()
		-- require("dap-python").setup('/Volumes/Samsung/Software/michael/rock_paper_scissors/venv/bin/python')	
		require("dap-python").setup()
	end

}
