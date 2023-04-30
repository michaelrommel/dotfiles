local lazyopts = require("plugins.conf_lazy").opts
local icons = require("core.theme").icons

local fn = vim.fn

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
			"nvim-tree/nvim-web-devicons",
			"ellisonleao/gruvbox.nvim",
		}
	},
	-- the colour scheme
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("plugins.conf_gruvbox").setup()
		end,
	},
	-- some decorative icons used in the statusline and completion menus as well as
	-- the tree
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	},
	-- an installer for language servers and debug adapters
	{
		"williamboman/mason.nvim",
		lazy = true,
		config = function()
			require("mason").setup()
		end,
	},
	-- an implementation of the Debug Adapter Protocol for nvim
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		ft = { "python", "javascript" },
		config = function()
			-- register key mappings for working in debug mode
			require("core.mappings").dap_mappings()
			-- set up the javascript adapter, the nvim-dap-vscode-js does not work
			require("plugins.conf_dap").setup()
		end,
		dependencies = {
			-- this ensures that mason autoinstalls the mentioned adapters
			{
				"jay-babu/mason-nvim-dap.nvim",
				lazy = true,
				ft = { "python", "javascript" },
				config = function()
					require("mason-nvim-dap").setup({
						ensure_installed = { "js-debug-adapter", "debugpy" }
					})
				end,
			},
			-- this configures the python adapter
			-- make sure that in the top level directory there is alqays
			-- a pyproject.toml file with settings for venv and pyright
			{
				"mfussenegger/nvim-dap-python",
				lazy = true,
				config = function()
					-- require("dap-python").setup('/Volumes/Samsung/Software/michael/rock_paper_scissors/venv/bin/python')	
					require("dap-python").setup()
				end
			},
			-- a TUI interface for the debug adapter
			{
				"rcarriga/nvim-dap-ui",
				lazy = true,
				config = function()
					require("dapui").setup()
				end
			},

		}
	},
	-- this extends the builtin treesitter and autoloads additional language
	-- grammars when a buffer is opened
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
	{
		"hrsh7th/vim-vsnip",
		dependencies = {
			-- a collection of many programming language snippets
			"rafamadriz/friendly-snippets",
		},
	},
	-- this automatically inserts closing quotes or brackets
	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	-- a completion engine, that can get suggestions from different sources
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		event = "InsertEnter",
		dependencies = {
			-- get suggestions from language servers
			"hrsh7th/cmp-nvim-lsp",
			-- get text fragments from current buffer, mostly sensible for
			-- markdown texts or so
			"hrsh7th/cmp-buffer",
			-- can suggest filenames from the local filesystem
			"hrsh7th/cmp-path",
			-- provides vim commandline completions
			"hrsh7th/cmp-cmdline",
			-- completions for the nvim lua api
			"hrsh7th/cmp-nvim-lua",
			-- vsips provider
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
		},
		config = function()
			local cmp = require("cmp")
			local cmp_mappings = require("core.mappings").cmp_mappings()
			cmp.setup({
				experimental = {
					ghost_text = { hl_group = 'Comment' }
				},
				completion = {
					autocomplete = false,
				},
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args)
						fn["vsnip#anonymous"](args.body)
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
							vim_item.kind = string.format('%s %s', icons[vim_item.kind], vim_item.kind)
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
				mapping = cmp.mapping.preset.insert(cmp_mappings),
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
	-- autoinstaller for language servers' configurations
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true,
		ft = { "bash", "css", "graphql", "html", "json", "json5", "lua", "python", "rust", "svelte", "javascript" },
		dependencies = {
			"williamboman/mason.nvim",
			-- language server configuration
			"neovim/nvim-lspconfig",
			"hrsh7th/nvim-cmp",
			-- separates the update intervals of lsp from autosaved files/buffers
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

			local on_attach = require("plugins.conf_lsp").on_attach

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
	-- fallback language server, that can use external programs for linting
	-- and autoformatting
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			-- asynchronous lib for lua
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local nls = require("null-ls")
			local on_attach = require("plugins.conf_lsp").on_attach
			nls.setup({
				debug = true,
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "package.json", "Makefile", ".git"),
				sources = {
					nls.builtins.formatting.shfmt,
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
	-- small commeing/uncommenting plugin
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = "BufEnter",
		config = function()
			require('Comment').setup()
		end
	},
	-- lists git status and diff lines in the left signcolumn
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "BufEnter",
		config = function()
			require('gitsigns').setup()
		end
	},
	-- visually draws vertical lines for code blocks
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
	-- offers a "help" function for key mappings
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
			require("core.mappings").std_mappings()
		end,
	},
	-- explorer style tree on the left
	{
		"nvim-tree/nvim-tree.lua",
		lazy = true,
		version = "*",
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer Tree" },
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {
				view = {
					width = 50,
					mappings = {
						list = {
						}
					}
				}
			}
		end,
	}
}, lazyopts)
