-- manages crates.io dependencies
return {
	"saecki/crates.nvim",
	lazy = true,
	event = { "BufRead Cargo.toml" },
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local crates = require("crates")
		local cm = require("core.mappings")
		crates.setup({
			on_attach = cm.crates_mappings,
			-- open_programs = { "open", "wslview", "xdg-open" },
			popup = {
				autofocus = true,
				border = "rounded",
			},
		})
	end
}
