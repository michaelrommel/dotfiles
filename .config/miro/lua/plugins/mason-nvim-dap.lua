-- this ensures that mason autoinstalls the mentioned adapters
return {
	"jay-babu/mason-nvim-dap.nvim",
	lazy = true,
	ft = { "python", "javascript" },
	dependencies = {
		"williamboman/mason.nvim"
	},
	config = function()
		require("mason-nvim-dap").setup({
			ensure_installed = { "js", "python" }
		})
	end,
}
