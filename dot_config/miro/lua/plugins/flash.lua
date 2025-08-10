return {
	"folke/flash.nvim",
	lazy = true,
	event = "VeryLazy",
	opts = {
		modes = {
			search = {
				enabled = false
			},
			char = {
				config = function(opts)
					-- autohide flash when in operator-pending mode
					opts.autohide = opts.autohide or (vim.fn.mode(true):find("no") and vim.v.operator == "y")

					-- disable jump labels when not enabled, when using a count,
					-- or when recording/executing registers
					opts.jump_labels = opts.jump_labels
						and vim.v.count == 0
						and vim.fn.reg_executing() == ""
						and vim.fn.reg_recording() == ""

					-- Show jump labels only in operator-pending mode
					opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):find("o")
				end,
				jump_labels = true,
			}
		},
		prompt = {
			enabled = true,
			prefix = { { "⚡", "FlashPromptIcon" } },
			win_config = {
				relative = "editor",
				width = 1, -- when <=1 it's a percentage of the editor width
				height = 1,
				row = -1, -- when negative it's an offset from the bottom
				col = 0, -- when negative it's an offset from the right
				zindex = 1000,
			},
		},
	},
}
