local M = {}
local fn = vim.fn
local lsp = vim.lsp
local diagnostic = vim.diagnostic

M.std_mappings = function()
	local wk = require("which-key")
	local ts = require("telescope")
	local tb = require("telescope.builtin")
	local tsc = require("configs.conf_telescope")
	local tc = require("todo-comments")
	local flsh = require("flash")
	local oil = require("oil")
	local tts = require("nvim-treesitter-textobjects.select")

	local ttc = require("configs.conf_toggleterm")
	local term = require("toggleterm.terminal").Terminal
	local miniterm = term:new(ttc.miniterm_opts)
	local function miniterm_toggle()
		miniterm:toggle()
	end
	local function insert_datetime()
		local output = vim.fn.systemlist("date -Iseconds")
		local pos = vim.api.nvim_win_get_cursor(0)[2]
		local line = vim.api.nvim_get_current_line()
		local nline = line:sub(0, pos + 1) .. output[1] .. line:sub(pos + 2)
		vim.api.nvim_set_current_line(nline)
	end

	-- remove the default mapping of Y to y$
	vim.keymap.del("n", "Y")

	wk.add({
		mode = { "x", "o" },
		-- moves the cursor left and right in insert mode
		{
			"a=",
			function()
				tts.select_textobject("@assignment.outer", "textobjects")
			end,
			desc = "around assignment",
		},
		{
			"i=",
			function()
				tts.select_textobject("@assignment.inner", "textobjects")
			end,
			desc = "inside assignment",
		},
		{
			"=l",
			function()
				tts.select_textobject("@assignment.lhs", "textobjects")
			end,
			desc = "left hand side",
		},
		{
			"=r",
			function()
				tts.select_textobject("@assignment.rhs", "textobjects")
			end,
			desc = "right hand side",
		},
		{
			"aa",
			function()
				tts.select_textobject("@parameter.outer", "textobjects")
			end,
			desc = "around parameter",
		},
		{
			"ia",
			function()
				tts.select_textobject("@parameter.inner", "textobjects")
			end,
			desc = "inside parameter",
		},
		{
			"al",
			function()
				tts.select_textobject("@loop.outer", "textobjects")
			end,
			desc = "around loop",
		},
		{
			"il",
			function()
				tts.select_textobject("@loop.inner", "textobjects")
			end,
			desc = "inside loop",
		},
		{
			"ac",
			function()
				tts.select_textobject("@call.outer", "textobjects")
			end,
			desc = "around call",
		},
		{
			"ic",
			function()
				tts.select_textobject("@call.inner", "textobjects")
			end,
			desc = "inside call",
		},
		{
			"af",
			function()
				tts.select_textobject("@function.outer", "textobjects")
			end,
			desc = "around function",
		},
		{
			"if",
			function()
				tts.select_textobject("@function.inner", "textobjects")
			end,
			desc = "inside function",
		},
	})
	wk.add({
		mode = { "i", "v" },
		-- moves the cursor left and right in insert mode
		{ "<C-h>", "<Left>", desc = "Move 1 char left" },
		{ "<C-l>", "<Right>", desc = "Move 1 char right" },
	})
	wk.add({
		{
			"<C-c>",
			function()
				miniterm_toggle()
			end,
			desc = "Toggle Mini Terminal",
		},
		{ "<C-h>", "<C-w>h", desc = "Left split" },
		{ "<C-j>", "<C-w>j", desc = "Lower split" },
		{ "<C-k>", "<C-w>k", desc = "Upper split" },
		{ "<C-l>", "<C-w>l", desc = "Right split" },
		{
			"[t",
			function()
				tc.jump_prev()
			end,
			desc = "Previous TODO",
		},
		{
			"]t",
			function()
				tc.jump_next()
			end,
			desc = "Next TODO",
		},
		{
			"-",
			function()
				oil.open_float()
			end,
			desc = "Open Oil file manager",
		},
	})
	wk.add({
		-- ['/'] = { function() flsh.jump() end, "Search with flash" },
		-- x = visual mode only, o = operator pending mode
		{
			"S",
			function()
				flsh.treesitter()
			end,
			desc = "Search Treesitter tags with flash",
			mode = { "n", "x" },
		},
	})
	wk.add({
		{ "<C-q>", "<C-\\><C-n>", desc = "Put terminal in Normal mode", mode = "t" },
	})
	wk.add({
		mode = { "v" },
		{ "<leader>s", group = "Silicon" },
		{
			"<leader>sc",
			function()
				require("nvim-silicon").clip()
			end,
			desc = "Copy code screenshot to clipboard",
		},
		{
			"<leader>sf",
			function()
				require("nvim-silicon").file()
			end,
			desc = "Save code screenshot as file",
		},
		{
			"<leader>ss",
			function()
				require("nvim-silicon").shoot()
			end,
			desc = "Create code screenshot",
		},
	})
	wk.add({
		{ "<leader>b", group = "Browse" },
		{
			"<leader>bd",
			function()
				require("browse.devdocs").search()
			end,
			desc = "DevDocs",
		},
		{
			"<leader>bg",
			function()
				require("browse").input_search()
			end,
			desc = "Google",
		},
		-- find functions with telescope
		{ "<leader>f", group = "Find" },
		{
			"<leader>fb",
			function()
				tb.buffers()
			end,
			desc = "Find buffers",
		},
		{
			"<leader>fc",
			function()
				ts.extensions.neoclip.default()
			end,
			desc = "Find clipboard",
		},
		{
			"<leader>fd",
			function()
				tb.diagnostics()
			end,
			desc = "Find diagnostics",
		},
		{
			"<leader>ff",
			function()
				tb.find_files({
					find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
				})
			end,
			desc = "Find files",
		},
		{
			"<leader>fg",
			function()
				tb.live_grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>fp",
			function()
				tsc.find_files_from_project_git_root()
			end,
			desc = "Find files in project",
		},
		-- clears search highlighting
		{ "<leader>h", "<cmd>nohl<cr>", desc = "Hide search highlights" },
		{
			"<leader>H",
			function()
				vim.diagnostic.hide()
			end,
			desc = "Hide diagnostics",
		},
		{ "<leader>s", group = "Shortcuts" },
		{ "<leader>sd", insert_datetime, desc = "Insert a ISO DateTimestamp" },
	})
end

M.gitsigns_mappings = function(bufnr)
	local wk = require("which-key")
	local gs = package.loaded.gitsigns
	wk.add({
		{ "<leader>g", group = "Git" },
		{
			"<leader>gD",
			function()
				gs.diffthis("~")
			end,
			buffer = bufnr,
			desc = "Diff ~ (last commit)",
		},
		{ "<leader>gR", gs.reset_buffer, buffer = bufnr, desc = "Reset buffer" },
		{ "<leader>gS", gs.stage_buffer, buffer = bufnr, desc = "Stage buffer" },
		{
			"<leader>gb",
			function()
				gs.blame_line({ full = true })
			end,
			buffer = bufnr,
			desc = "Blame line",
		},
		{ "<leader>gd", gs.diffthis, buffer = bufnr, desc = "Diff" },
		{ "<leader>gp", gs.preview_hunk, buffer = bufnr, desc = "Preview hunk" },
		{ "<leader>gr", gs.reset_hunk, buffer = bufnr, desc = "Reset hunk" },
		{ "<leader>gs", gs.stage_hunk, buffer = bufnr, desc = "Stage hunk" },
		{ "<leader>gt", group = "Toggles" },
		{ "<leader>gtb", gs.toggle_current_line_blame, buffer = bufnr, desc = "Toggle blame" },
		{ "<leader>gtd", gs.toggle_deleted, buffer = bufnr, desc = "Toggle deleted" },
		{ "<leader>gu", gs.undo_stage_hunk, buffer = bufnr, desc = "Undo stage hunk" },
	})
	wk.add({
		{
			"<leader>gr",
			function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end,
			buffer = bufnr,
			desc = "Reset hunk",
			mode = "v",
		},
		{
			"<leader>gs",
			function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end,
			buffer = bufnr,
			desc = "Stage hunk",
			mode = "v",
		},
	})
	wk.add({
		{
			"[h",
			function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.prev_hunk()
				end)
				return "<Ignore>"
			end,
			buffer = bufnr,
			desc = "Previous hunk",
			expr = true,
			replace_keycodes = false,
		},
		{
			"]h",
			function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					gs.next_hunk()
				end)
				return "<Ignore>"
			end,
			buffer = bufnr,
			desc = "Next hunk",
			expr = true,
			replace_keycodes = false,
		},
	})
	wk.add({
		{ "ih", buffer = bufnr, desc = ":<C-U>Gitsigns select_hunk<cr>", mode = { "o", "x" } },
	})
end

M.dap_mappings = function()
	-- the debug adapter protocol can open modal floating windows, this mapping allows
	-- the Esc key to close them
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dap-float",
		callback = function()
			vim.keymap.set("n", "<Esc>", "<cmd>close!<CR>", { buffer = true, noremap = true, silent = true })
		end,
	})
	local wk = require("which-key")
	-- standard key mappings
	wk.add({
		-- step into the function: mnemonic debug in
		{
			"<C-S-i>",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		-- step over the function: mnemonic debug jump over
		{
			"<C-S-j>",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		-- terminate debugging session: mnemonic kill debugger
		{
			"<C-S-k>",
			function()
				require("dap").terminate()
			end,
			desc = "Kill/Stop Debugger",
		},
		-- step out to the calling function: mnemonic out
		{
			"<C-S-o>",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		-- start debugging: mnemonic play
		{
			"<C-S-p>",
			function()
				require("dap").continue()
			end,
			desc = "Play",
		},
	})
	-- document the leader key mappings
	wk.add({
		{ "<Leader>d", group = "Debug" },
		-- re-start the debug session: mnemonic debug again
		{
			"<Leader>da",
			function()
				require("dap").run_last()
			end,
			desc = "Again the last run",
		},
		-- toggle a breakpoint: mnemonic debug breakpoint
		{
			"<Leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Breakpoint Toggle",
		},
		-- continue the debugging: mnemonic debug continue
		{
			"<Leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
		},
		-- show the stack frames, can navigate around the call stack: mnemonic debug frames
		{
			"<Leader>df",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end,
			desc = "Frames on the stack",
		},
		-- show variable or function status inspector: mnemonic debug hover
		{
			"<Leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "Hover",
		},
		-- set a log point: mnemonic debug logmessage
		{
			"<Leader>dl",
			function()
				require("dap").set_breakpoint(nil, nil, fn.input("Log point message: "))
			end,
			desc = "Log Point",
		},
		-- open a repl, switch to insert mode for a prompt: mnemonic debug open
		{
			"<Leader>do",
			function()
				require("dap").repl.open()
			end,
			desc = "Open REPL",
		},
		-- show variables or function status inspector in a separate split: mnemonic debug preview
		{
			"<Leader>dp",
			function()
				require("dap.ui.widgets").preview()
			end,
			desc = "Preview",
		},
		-- start the debugging: mnemonic debug run
		{
			"<Leader>dr",
			function()
				if vim.bo.filetype == "javascript" then
					local addr = fn.input("Host: ", "127.0.0.1")
					require("dap").configurations["javascript"][2]["address"] = addr
				end
				require("dap").continue()
			end,
			desc = "Run",
		},
		-- show the variables in all scopes: mnemonic debug scopes
		{
			"<Leader>ds",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end,
			desc = "Scopes",
		},
		-- show the whole debugging ui: mnemonic debug ui
		{
			"<Leader>du",
			function()
				-- require('dapui').setup()
				require("dapui").toggle()
			end,
			desc = "UI display",
		},
	})
end

M.lsp_mappings = function(bufnr)
	local wk = require("which-key")
	local function show_documentation()
		local filetype = vim.bo.filetype
		if vim.tbl_contains({ "vim", "help" }, filetype) then
			vim.cmd("h " .. vim.fn.expand("<cword>"))
		elseif vim.tbl_contains({ "man" }, filetype) then
			vim.cmd("Man " .. vim.fn.expand("<cword>"))
		elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
			require("crates").show_popup()
		else
			vim.lsp.buf.hover()
		end
	end
	wk.add({
		-- ['K'] = { lsp.buf.hover, "Show LSP symbol info" },
		{ "K", show_documentation, buffer = bufnr, desc = "Show LSP symbol info / docs", remap = false },
		{ "g", group = "Goto", remap = false },
		{ "gr", group = "Goto LSP References", remap = false },
		{ "grD", lsp.buf.declaration, buffer = bufnr, desc = "Goto declaration", remap = false },
		{ "grd", lsp.buf.definition, buffer = bufnr, desc = "Goto definition", remap = false },
		{ "grs", lsp.buf.signature_help, buffer = bufnr, desc = "Show LSP function signature", remap = false },
	})
	wk.add({
		{
			"<leader>D",
			diagnostic.open_float,
			buffer = bufnr,
			desc = "Open diagnostics float",
			remap = false,
		},
		{
			"<leader>A",
			function()
				require("actions-preview").code_actions()
			end,
			buffer = bufnr,
			desc = "Code actions preview",
			remap = false,
		},
		{
			"<leader>q",
			diagnostic.setloclist,
			buffer = bufnr,
			desc = "Open quickfix window",
			remap = false,
		},
		{ "<leader>r", group = "Rename", remap = false },
		{
			"<leader>rn",
			lsp.buf.rename,
			buffer = bufnr,
			desc = "Rename all symbol occurrences",
			remap = false,
		},
		{
			"<leader>t",
			lsp.buf.type_definition,
			buffer = bufnr,
			desc = "Goto type definition",
			remap = false,
		},
		{ "<leader>w", group = "Workspace", remap = false },
		{
			"<leader>wa",
			lsp.buf.add_workspace_folder,
			buffer = bufnr,
			desc = "Add workspace folder",
			remap = false,
		},
		{
			"<leader>wl",
			function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end,
			buffer = bufnr,
			desc = "List all workspaces",
			remap = false,
		},
		{
			"<leader>wr",
			lsp.buf.remove_workspace_folder,
			buffer = bufnr,
			desc = "Remove workspace folder",
			remap = false,
		},
	})
end

M.crates_mappings = function(bufnr)
	local wk = require("which-key")
	local crates = require("crates")
	wk.add({
		{ "<leader>c", group = "Crates", remap = false },
		{
			"<leader>cA",
			crates.upgrade_all_crates,
			buffer = bufnr,
			desc = "Crates.io",
			remap = false,
		},
		{
			"<leader>cC",
			crates.open_crates_io,
			buffer = bufnr,
			desc = "Crates.io",
			remap = false,
		},
		{
			"<leader>cD",
			crates.open_documentation,
			buffer = bufnr,
			desc = "Documentation",
			remap = false,
		},
		{
			"<leader>cE",
			crates.extract_crate_into_table,
			buffer = bufnr,
			desc = "Extract into table",
			remap = false,
		},
		{
			"<leader>cH",
			crates.open_homepage,
			buffer = bufnr,
			desc = "Homepage",
			remap = false,
		},
		{
			"<leader>cR",
			crates.open_repository,
			buffer = bufnr,
			desc = "Repository",
			remap = false,
		},
		{
			"<leader>cU",
			crates.upgrade_crate,
			buffer = bufnr,
			desc = "Upgrade crate",
			remap = false,
		},
		{
			"<leader>ca",
			crates.update_all_crates,
			buffer = bufnr,
			desc = "Update all crates",
			remap = false,
		},
		{
			"<leader>cd",
			crates.show_dependencies_popup,
			buffer = bufnr,
			desc = "Dependencies",
			remap = false,
		},
		{
			"<leader>ce",
			crates.expand_plain_crate_to_inline_table,
			buffer = bufnr,
			desc = "Expand to table",
			remap = false,
		},
		{
			"<leader>cf",
			crates.show_features_popup,
			buffer = bufnr,
			desc = "Features",
			remap = false,
		},
		{
			"<leader>cr",
			crates.reload,
			buffer = bufnr,
			desc = "Reload",
			remap = false,
		},
		{
			"<leader>ct",
			crates.toggle,
			buffer = bufnr,
			desc = "Toggle",
			remap = false,
		},
		{
			"<leader>cu",
			crates.update_crate,
			buffer = bufnr,
			desc = "Update crate",
			remap = false,
		},
		{
			"<leader>cv",
			crates.show_versions_popup,
			buffer = bufnr,
			desc = "Versions",
			remap = false,
		},
	})
end

return M
