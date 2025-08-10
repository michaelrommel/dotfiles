-- lists git status and diff lines in the left signcolumn
return {
	"lewis6991/gitsigns.nvim",
	lazy = true,
	event = "BufEnter",
	config = function()
		local cm = require("core.mappings")
		require("gitsigns").setup({
			on_attach = cm.gitsigns_mappings,
			current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d>: <summary>",
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
				delay = 500,
				ignore_whitespace = false,
			},
		})
	end
}
