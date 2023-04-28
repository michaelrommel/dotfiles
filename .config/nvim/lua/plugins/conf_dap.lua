local M = {}

M.setup = function()
	-- the debug adapter protocol can open modal floating windows, this mapping allows
	-- the Esc key to close them
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dap-float",
		callback = function(args)
			vim.keymap.set('n', '<Esc>', "<cmd>close!<CR>", { buffer = true, noremap = true, silent = true })
		end
	})
	local wk = require("which-key")
	-- standard key mappings
	-- step into the function: mnemonic debug in
	vim.keymap.set('n', '<C-i>', function() require('dap').step_into() end)
	-- step over the function: mnemonic debug jump over
	vim.keymap.set('n', '<C-j>', function() require('dap').step_over() end)
	-- step out to the calling function, no mnemonic, just an unused key in that area
	vim.keymap.set('n', '<C-k>', function() require('dap').step_out() end)
	-- document the leader key mappings
	wk.register({
		d = {
			name = "debug",
			-- start the debugging: mnemonic debug run
			r = { function() require('dap').continue() end, "Run/Continue" },
			-- toggle a breakpoint: mnemonic debug breakpoint
			b = { function() require('dap').toggle_breakpoint() end, "Breakpoint Toggle" },
			B = { function() require('dap').set_breakpoint() end, "Breakpoint Set" },
			-- set a log point: mnemonic debug logmessage
			l = { function() require('dap').set_breakpoint(nil, nil, fn.input('Log point message: ')) end,
				"Log Point" },
			-- open a repl, switch to insert mode for a prompt: mnemonic debug open
			o = { function() require('dap').repl.open() end, "Open REPL" },
			-- re-start the debug session: mnemonic debug again
			a = { function() require('dap').run_last() end, "Again the last run" },
			-- show variable or function status inspector: mnemonic debug hover
			h = { function() require('dap.ui.widgets').hover() end, "Hover" },
			-- show variables or function status inspector in a separate split: mnemonic debug preview
			p = { function() require('dap.ui.widgets').preview() end, "Preview" },
			-- show the stack frames, can navigate around the call stack: mnemonic debug frames
			f = { function()
				local widgets = require('dap.ui.widgets')
				widgets.centered_float(widgets.frames)
			end, "Frames on the stack" },
			-- show the variables in all scopes: mnemonic debug scopes
			s = { function()
				local widgets = require('dap.ui.widgets')
				widgets.centered_float(widgets.scopes)
			end, "Scopes" },
			-- show the whole debugging ui: mnemonic debug ui
			u = { function()
				require('dapui').toggle()
			end, "UI display" },
		}
	}, { prefix = "<Leader>" })
end


return M
