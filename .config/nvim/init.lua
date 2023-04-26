local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local function utf8(decimal)
	local bytemarkers = { { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } }
	if decimal < 128 then return string.char(decimal) end
	local charbytes = {}
	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local mod = decimal % 64
				decimal = (decimal - mod) / 64
				charbytes[b] = string.char(128 + mod)
			end
			charbytes[1] = string.char(vals[2] + decimal)
			break
		end
	end
	return table.concat(charbytes)
end

-- this is the standard leader for neovim in many configurations
vim.g.mapleader = " "

-- This enables 24 bit aka Truecolor. Also switches to using guifg
-- attributes instead of cterm attributes:
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1"

vim.opt.listchars = { tab = utf8(0xBB) .. ' ', trail = utf8(0xB7), nbsp = '~' }
vim.opt.list = true
vim.opt.showmode = false
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.mouse = "a"
vim.opt.ruler = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = false

-- disable some default providers
for _, provider in ipairs { "node", "perl", "ruby" } do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end

local function gruvbox_setup()
	-- setup must be called before loading the colorscheme
	require("gruvbox").setup({
		undercurl = true,
		underline = true,
		bold = true,
		italic = {
			strings = false,
			comments = true,
			operators = false,
			folds = true,
		},
		strikethrough = true,
		invert_selection = false,
		invert_signs = false,
		invert_tabline = false,
		invert_intend_guides = false,
		inverse = true, -- invert background for search, diffs, statuslines and errors
		contrast = "hard", -- can be "hard", "soft" or empty string
		palette_overrides = {},
		overrides = {},
		dim_inactive = false,
		transparent_mode = false,
	})
	vim.cmd([[colorscheme gruvbox]])
	vim.cmd([[highlight link FloatBorder NormalFloat]])
	-- Change diagnostic signs to be consistent with defaults from nvim-lualine
	vim.fn.sign_define("DiagnosticSignError", { text = utf8(0xf659), texthl = "DiagnosticSignError" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = utf8(0xf529), texthl = "DiagnosticSignWarn" })
	vim.fn.sign_define("DiagnosticSignInformation", { text = utf8(0xf7fc), texthl = "DiagnosticSignInfo" })
	vim.fn.sign_define("DiagnosticSignHint", { text = utf8(0xf835), texthl = "DiagnosticSignHint" })
end

-- define here, that removes lspkind as another module
local kind_icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "塞",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = ""
}

local function dap_setup()
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
			l = { function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
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

local deprecatedFormatters = { "tsserver", "jsonls" }

-- needs to be a global to be used also as formatexpr
function Lsp_formatting(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			-- local deprecated = false
			-- for _, n in ipairs(deprecatedFormatters) do
			-- 	deprecated = deprecated or client.name == n
			-- end
			-- if not deprecated then
			-- 	print(client.name)
			-- end
			-- return not deprecated
			return true
		end,
		bufnr = bufnr,
	})
end

local function on_attach(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- print(string.format("%s -> %s", client.name, client.server_capabilities.documentRangeFormattingProvider))
	if client.supports_method("textDocument/formatting") then
		local deprecated = false
		for _, n in ipairs(deprecatedFormatters) do
			deprecated = deprecated or client.name == n
		end
		if deprecated then
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		else
			local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					Lsp_formatting(bufnr)
				end,
			})
			-- we can use the lsp formatter also for gq commands
			vim.api.nvim_buf_set_option(bufnr, "formatexpr", 'v:lua.Lsp_formatting()')
		end
	end

	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = 'rounded',
				source = 'always',
				prefix = ' ',
				scope = 'cursor',
			}
			vim.diagnostic.open_float(nil, opts)
		end
	})

	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
	vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
	vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
	vim.keymap.set('n', '<Leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, opts)
	vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
	vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)
end

require("lazy").setup({
	{
		-- bare necessities statusline in vim, shows git status, filetype, encoding
		-- and cursor position without much configuration
		"nvim-lualine/lualine.nvim",
		lazy = false,
		config = function()
			require("lualine").setup({
				options = {
					theme = 'gruvbox',
				},
				sections = {
					lualine_y = { "progress", "selectioncount" }
				}
			})
		end,
		dependencies = {
			{
				"nvim-tree/nvim-web-devicons",
				config = function()
					require("nvim-web-devicons").setup({ default = true })
				end,
			},
			{
				"ellisonleao/gruvbox.nvim",
				-- lazy = false, -- make sure we load this during startup if it is your main
				-- colorscheme, but since it is in a dependency of a non-lazy loaded plugin, this
				-- is probably not needed (and does not work here in a dependency anyhow
				priority = 1000, -- make sure to load this before all the other start plugins
				config = function()
					gruvbox_setup()
				end,
			},
		}
	},
	{
		"williamboman/mason.nvim",
		lazy = true,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		ft = { "python", "javascript" },
		config = function()
			dap_setup()
		end,
		dependencies = {
			-- {
			-- 	"jay-babu/mason-nvim-dap.nvim",
			-- 	config = function()
			-- 		require("mason-nvim-dap").setup()
			-- 	end,
			-- },
			{
				"mfussenegger/nvim-dap-python",
				lazy = true,
				config = function()
					-- require("dap-python").setup('/Volumes/Samsung/Software/michael/rock_paper_scissors/venv/bin/python')	
					require("dap-python").setup()
				end
			},
			{
				"rcarriga/nvim-dap-ui",
				lazy = true,
				config = function()
					require("dapui").setup()
				end
			},

		}
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = true,
		event = "BufEnter",
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		config = function()
			require("nvim-treesitter.configs").setup({
				-- ensure_installed = { "c", "lua", "query", "vim", "vimdoc"}
				-- ensure_installed = { "bash", "cpp", "css", "diff", "dockerfile", "gitcommit", "gitignore", "go", "graphql", "html", "http", "ini", "javascript", "jq", "jsdoc", "json", "jsonc", "json5", "make", "markdown", "mermaid", "python", "regex", "rust", "svelte", "toml", "yaml" },
				auto_install = true,
				highlight = {
					enable = true,
				}
			})
		end,
	},
	-- snippets
	-- {
	-- 	"L3MON4D3/LuaSnip",
	-- 	dependencies = {
	-- 		"rafamadriz/friendly-snippets",
	-- 		config = function()
	-- 			require("luasnip.loaders.from_vscode").lazy_load()
	-- 		end,
	-- 	},
	-- 	config = function()
	-- 		local types = require("luasnip.util.types")
	-- 		require("luasnip").setup({
	-- 			opts = {
	-- 				history = true,
	-- 				delete_check_events = "TextChanged",
	-- 				enable_autosnippets = false,
	-- 			},
	-- 			ext_opts = {
	-- 				-- mark the types of snippets fields with colors
	-- 				[types.choiceNode] = {
	-- 					active = {
	-- 						virt_text = { { "●", "GruvboxOrange" } }
	-- 					}
	-- 				},
	-- 				[types.insertNode] = {
	-- 					active = {
	-- 						virt_text = { { "●", "GruvboxBlue" } }
	-- 					}
	-- 				}
	-- 			},
	-- 		})
	-- 	end,
	-- 	keys = {
	-- 		-- {
	-- 		-- 	"<tab>",
	-- 		-- 	function()
	-- 		-- 		return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
	-- 		-- 	end,
	-- 		-- 	expr = true,
	-- 		-- 	silent = true,
	-- 		-- 	mode = "i",
	-- 		-- },
	-- 		-- { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
	-- 		-- { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
	-- 	},
	-- },
	{
		"hrsh7th/vim-vsnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
			-- config = function()
			-- 	require("luasnip.loaders.from_vscode").lazy_load()
			-- end,
		},
	},
	-- auto pairs
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		config = function(_, opts)
			require("mini.pairs").setup(opts)
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lua",
			-- "saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
		},
		config = function()
			local cmp = require("cmp")
			--local luasnip = require("luasnip")
			vim.opt.completeopt = "menu,menuone,noselect"
			cmp.config.preselect = cmp.PreselectMode.None
			-- cmp.config.experimental = { ghost_text = true }
			cmp.config.experimental = { ghost_text = { hl_group = 'Comment' } }
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and
					vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end
			local feedkey = function(key, mode)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
			end
			cmp.setup({
				snippet = {
					expand = function(args)
						-- luasnip.lsp_expand(args.body)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = function(entry, vim_item)
						-- print(string.format("%s -> %s", entry.source.name, vim_item))
						if vim.tbl_contains({ 'path' }, entry.source.name) then
							local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item()
								.label)
							if icon then
								vim_item.kind = string.format('%s %s', icon, vim_item.kind)
								vim_item.kind_hl_group = hl_group
							end
						else
							vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
						end
						vim_item.menu = ({
							buffer = "[buf]",
							nvim_lsp = "[lsp]",
							luasnip = "[lsnip]",
							vsnip = "[vsnip]",
							nvim_lua = "[lua]",
						})[entry.source.name]
						return vim_item
					end
				},
				-- the helper builds groups, second group will not
				-- show, while the first one is available
				sources = cmp.config.sources({
					-- { name = 'luasnip' },
					{ name = 'vsnip' },
					{ name = 'nvim_lsp' },
					{ name = 'path' },
				}, {
					{ name = "buffer" }
				}),
				mapping = cmp.mapping.preset.insert({
					-- scroll the documentation, if an entry provides it
					['<C-d>'] = cmp.mapping.scroll_docs(-4), -- Up
					['<C-f>'] = cmp.mapping.scroll_docs(4), -- Down
					-- C-b (back) C-f (forward) for snippet placeholder navigation.
					-- opens the menu if it does not automatically appear
					['<C-Space>'] = cmp.mapping.complete(),
					-- confirm the current selection and close float
					['<CR>'] = cmp.mapping.confirm {
						-- behavior = cmp.ConfirmBehavior.Replace,
						-- do not autoselect the first item on <CR>
						select = false,
					},
					-- close float and do not accept completion
					['<Esc>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.abort()
						else
							fallback()
						end
					end, { 'i', 's' }),
					-- allow navigation inside the float with j and k
					['j'] = cmp.mapping(function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
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
						elseif vim.fn["vsnip#available"](1) == 1 then
							feedkey("<Plug>(vsnip-jump-next)", "")
							-- feedkey("<Plug>(vsnip-expand-or-jump)", "")
							-- elseif luasnip.expand_or_locally_jumpable() then
							-- 	luasnip.expand_or_jump()
							-- elseif has_words_before() then
							-- 	cmp.complete()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif vim.fn["vsnip#available"](-1) == 1 then
							feedkey("<Plug>(vsnip-jump-prev)", "")
							-- elseif luasnip.jumpable(-1) then
							-- 	luasnip.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				}),
			})
			cmp.setup.cmdline('/', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				})
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true,
		ft = { "bash", "css", "graphql", "html", "json", "json5", "lua", "python", "rust", "svelte", "javascript" },
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/nvim-cmp",
			"antoinemadec/FixCursorHold.nvim"
		},
		config = function()
			require('mason-lspconfig').setup({
				ensure_installed = { "bashls", "cssls", "graphql", "html", "lua_ls", "pyright",
					"rust_analyzer", "svelte", "tailwindcss", "tsserver" },
				-- automatic_installation = true,
			})

			-- inject default capabilities from completion module
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			-- print(vim.inspect(vim.tbl_keys(vim.lsp.handlers)))

			vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
			vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

			vim.g.cursorhold_updatetime = 500

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = false,
			})

			-- local rangeFormatter = vim.lsp.handlers["textDocument/rangeFormatter"]

			-- LSP settings (for overriding per client)
			-- local handlers = {
			-- 	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover),
			-- 	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help),
			-- }

			require("mason-lspconfig").setup_handlers {
				-- The first entry (without a key) will be the default handler
				function(server_name)
					require("lspconfig")[server_name].setup({
						on_attach = on_attach,
						capabilities = capabilities,
						--handlers = handlers
					})
				end,
				-- Next, you can provide a dedicated handler for specific servers.
				["lua_ls"] = function()
					require("lspconfig").lua_ls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									-- Get the language server to recognize the `vim` global
									globals = { 'vim' },
								},
								telemetry = {
									enable = false,
								},
							}
						}
					})
				end,
			}
		end
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local nls = require("null-ls")
			nls.setup({
				debug = true,
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "package.json", "Makefile", ".git"),
				sources = {
					-- nls.builtins.formatting.stylua,
					-- nls.builtins.formatting.shfmt,
					nls.builtins.code_actions.eslint.with({
						prefer_local = "node_modules/.bin",
					}),
					nls.builtins.diagnostics.eslint.with({
						prefer_local = "node_modules/.bin",
					}),
					nls.builtins.formatting.eslint.with({
						prefer_local = "node_modules/.bin",
					}),
					nls.builtins.code_actions.shellcheck,
					nls.builtins.diagnostics.shellcheck,
					nls.builtins.formatting.autopep8,
					-- nls.builtins.diagnostics.flake8,
					nls.builtins.formatting.prettier.with({
						filetypes = { "html", "json", "jsonc", "json5", "yaml", "markdown" },
						extra_args = function(params)
							print(string.format("%s", params))
							if params.filetype == "json5" then
								return { "--parser", "json5", "--use-tabs", "--quote-props", "preserve" }
							else
								return { "--use-tabs", "--semi", "--single-quote", "--trailing-comma none" }
							end
						end
					}),
				},
				on_attach = on_attach,
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = "BufEnter",
		config = function()
			require('Comment').setup()
		end
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "BufEnter",
		config = function()
			require('gitsigns').setup()
		end
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = true,
		event = "BufEnter",
		config = function()
			require("indent_blankline").setup {
				show_current_context = true,
				show_current_context_start = false,
			}
		end
	},
	{
		"folke/which-key.nvim",
		lazy = true,
		event = "VeryLazy",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 600
			require("which-key").setup({
				-- window = { border = "rounded" },
			})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {
				view = {
					width = 40,
					mappings = {
						list = {
						}
					}
				}
			}
		end,
	}
})
-- vim: sw=4:ts=4
