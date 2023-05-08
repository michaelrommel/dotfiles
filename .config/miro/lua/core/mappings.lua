local M = {}
local fn = vim.fn
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

M.std_mappings = function()
	local wk = require("which-key")
	local ts = require("telescope.builtin")
	local tsc = require("configs.conf_telescope")
	local tc = require("todo-comments")
	local ttc = require("configs.conf_toggleterm")
	local term = require('toggleterm.terminal').Terminal
	local floatterm = term:new(ttc.floatterm_opts)
	local function floatterm_toggle()
		floatterm:toggle()
	end
	local miniterm = term:new(ttc.miniterm_opts)
	local function miniterm_toggle()
		miniterm:toggle()
	end

	wk.register({
		-- moves the cursor left and right in insert mode
		['<C-h>'] = { "<Left>", "Move 1 char left" },
		['<C-l>'] = { "<Right>", "Move 1 char right" },
		-- ['kj'] = { "<Esc>", "Alternative Escape" },
	}, { mode = { "i", "v" } })
	wk.register({
		-- jumps to splits
		['<C-h>'] = { "<C-w>h", "Left split" },
		['<C-j>'] = { "<C-w>j", "Lower split" },
		['<C-k>'] = { "<C-w>k", "Upper split" },
		['<C-l>'] = { "<C-w>l", "Right split" },
		['<C-c>'] = { function() miniterm_toggle() end, "Toggle Mini Terminal" },
		['<C-S-c>'] = { function() floatterm_toggle() end, "Toggle Terminal" },
		['[t'] = { function() tc.jump_prev() end, "Previous TODO" },
		[']t'] = { function() tc.jump_next() end, "Next TODO" },
	}, { mode = { "n" } })
	wk.register({
		-- jumps to splits
		['<C-q>'] = { "<C-\\><C-n>", "Put terminal in Normal mode" },
		-- ['kj'] = { "<C-\\><C-n>", "Put terminal in Normal mode" },
	}, { mode = { "t" } })
	wk.register({
		-- opens up the nvim tree
		['e'] = { function() require("nvim-tree").focus() end, "Open explorer tree" },
		-- clears search highlighting
		['c'] = { "<cmd>nohl<cr>", "Clear search highlights" },
		-- zen mode
		['z'] = { function() require("zen-mode").toggle() end, "Toggle zen mode" },
		-- find functions with telescope
		['f'] = {
			['f'] = { function() ts.find_files() end, "Find files" },
			['p'] = { function() tsc.find_files_from_project_git_root() end,
				"Find files in project" },
			['g'] = { function() ts.live_grep() end, "Live grep" },
			['b'] = { function() ts.buffers() end, "Find buffers" },
		}
	}, { prefix = "<leader>", mode = "n" })
end

M.cmp_mappings = function()
	local cmp = require("cmp")
	local has_words_before = function()
		unpack = unpack or table.unpack
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and
			vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end
	return {
		-- scroll the documentation, if an entry provides it
		['<C-y>'] = cmp.mapping.scroll_docs(-4), -- Up
		['<C-e>'] = cmp.mapping.scroll_docs(4), -- Down
		-- opens the menu if it does not automatically appear
		['<C-Space>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.abort()
			else
				-- print("complete()")
				cmp.complete()
			end
		end, { 's', 'i' }),
		-- confirm the current selection and close float
		['<CR>'] = cmp.mapping.confirm {
			-- replace rest of the word if in the middle
			behavior = cmp.ConfirmBehavior.Replace,
			-- do not autoselect the first item on <CR>
			select = false,
		},
		-- allow navigation inside the float with j and k
		['j'] = cmp.mapping(function(fallback)
			-- if cmp.visible() and cmp.get_active_entry() then
			-- actually enter the float also on j
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['k'] = cmp.mapping(function(fallback)
			if cmp.visible() and cmp.get_active_entry() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
		-- inside float, navigate up/down, also jump in snippets
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif fn["vsnip#available"](1) == 1 then
				feedkey("<Plug>(vsnip-expand-or-jump)", "")
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif fn["vsnip#available"](-1) == 1 then
				feedkey("<Plug>(vsnip-jump-prev)", "")
			else
				fallback()
			end
		end, { 'i', 's' }),
	}
end

M.dap_mappings = function()
	-- the debug adapter protocol can open modal floating windows, this mapping allows
	-- the Esc key to close them
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dap-float",
		callback = function()
			vim.keymap.set('n', '<Esc>', "<cmd>close!<CR>", { buffer = true, noremap = true, silent = true })
		end
	})
	local wk = require("which-key")
	-- standard key mappings
	wk.register({
		name = "Debug",
		-- step into the function: mnemonic debug in
		['<C-i>'] = { function() require('dap').step_into() end, "Step Into" },
		-- step over the function: mnemonic debug jump over
		['<C-j>'] = { function() require('dap').step_over() end, "Step Over" },
		-- step out to the calling function, no mnemonic, just an unused key in that area
		['<C-k>'] = { function() require('dap').step_out() end, "Step Out" },
	})
	-- document the leader key mappings
	wk.register({
		d = {
			name = "Debug",
			-- start the debugging: mnemonic debug run
			r = {
				function()
					if vim.bo.filetype == "javascript" then
						local addr = fn.input("Host: ", "127.0.0.1")
						require("dap").configurations["javascript"][2]["address"] = addr
					end
					require('dap').continue()
				end, "Run"
			},
			-- continue the debugging: mnemonic debug continue
			c = { function() require('dap').continue() end, "Continue" },
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
			end, "Frames on the stack"
			},
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

M.lsp_mappings = function(bufnr)
	local wk = require("which-key")
	wk.register({
		['gD'] = { lsp.buf.declaration, "Goto declaration" },
		['gd'] = { lsp.buf.definition, "Goto definition" },
		['gi'] = { lsp.buf.implementation, "Goto implementation" },
		['gr'] = { lsp.buf.references, "Goto references" },
		['K'] = { lsp.buf.hover, "Show LSP symbol info" },
		-- ['<C-k>'] = { lsp.buf.signature_help, "Show LSP function signature" },
		['[d]'] = { diagnostic.goto_prev, "Goto previous diagnostics" },
		[']d'] = { diagnostic.goto_next, "Goto next diagnostics" },
	}, { mode = "n", buffer = bufnr, noremap = true, silent = true })
	wk.register({
		-- opens up the nvim tree
		['t'] = { lsp.buf.type_definition, "Goto type definition" },
		['rn'] = { lsp.buf.rename, "Rename all symbol occurrences" },
		['D'] = { diagnostic.open_float, "Open diagnostics float" },
		['q'] = { diagnostic.setloclist, "Open quickfix window" },
		['wa'] = { lsp.buf.add_workspace_folder, "Add workspace folder" },
		['wr'] = { lsp.buf.remove_workspace_folder, "Remove workspace folder" },
		['wl'] = { function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, "List all workspaces" }
	}, { prefix = "<leader>", mode = "n", buffer = bufnr, noremap = true, silent = true })
end

return M
