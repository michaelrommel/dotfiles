-- opencode integration
return {
	"nickjvandyke/opencode.nvim",
	-- version = "*", -- Latest stable release
	commit = "8804ffb81f9784dcd0e9af43a2068fb55282c4dd",
	lazy = false,
	config = function()
		vim.g.opencode_opts = {
			-- Your configuration, if any; goto definition on the type or field for details
			lsp = {
				enabled = true,
			},
		}
		vim.o.autoread = true -- Required for `opts.events.reload`
	end,
}
