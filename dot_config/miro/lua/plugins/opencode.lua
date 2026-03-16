-- opencode integration
return {
	"nickjvandyke/opencode.nvim",
	version = "*", -- Latest stable release
	config = function()
		vim.g.opencode_opts = {
			-- Your configuration, if any; goto definition on the type or field for details
		}
		vim.o.autoread = true -- Required for `opts.events.reload`
	end,
}
