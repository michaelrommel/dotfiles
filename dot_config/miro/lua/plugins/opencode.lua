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
			server = {
				port = nil,
				start = function()
					require("opencode.terminal").start("opencode --port 4096", {
						width = math.max(128, math.floor(vim.o.columns * 0.35)),
					})
				end,
				stop = function()
					require("opencode.terminal").stop()
				end,
				toggle = function()
					require("opencode.terminal").toggle("opencode attach http://localhost:4096")
				end,
			},
		}
		vim.o.autoread = true -- Required for `opts.events.reload`
	end,
}
