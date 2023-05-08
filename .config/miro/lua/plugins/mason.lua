-- an installer for language servers and debug adapters
return {
	"williamboman/mason.nvim",
	lazy = true,
	config = function()
		require("mason").setup({
			ui = {
				border = "rounded"
			}
		})
	end,
}
