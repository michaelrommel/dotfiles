local lazyopts = require("plugins.conf_lazy").opts
local icons = require("core.theme").icons

local fn = vim.fn
local api = vim.api

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
			require("mason").setup({
				ui = {
					border = "rounded"
				}
			})
		end,
	},
	-- this ensures that mason autoinstalls the mentioned adapters
	{
		"jay-babu/mason-nvim-dap.nvim",
		lazy = true,
		ft = { "python", "javascript" },
		dependencies = {
			"williamboman/mason.nvim"
		},
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "js", "python" }
			})
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
			"jay-babu/mason-nvim-dap.nvim",
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
		lazy = true,
		dependencies = {
			-- a collection of many programming language snippets
			"rafamadriz/friendly-snippets",
		},
	},
	-- this automatically inserts closing quotes or brackets
	{
		"windwp/nvim-autopairs",
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	-- a completion engine, that can get suggestions from different sources
	{
		"michaelrommel/cmp-gitcommit",
		lazy = true,
		config = function()
			require("cmp-gitcommit").setup({})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		version = false,
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
			"michaelrommel/cmp-gitcommit",
		},
		config = function()
			local cmp = require("cmp")
			local cmp_mappings = require("core.mappings").cmp_mappings()
			-- print("registring autocommand")
			-- if vim.bo.filetype == "gitcommit" then
			-- 	cmp.setup.buffer({
			-- 		sources = cmp.config.sources({
			-- 			{ name = "conventionalcommits" }
			-- 		}, {
			-- 			{ name = "buffer" }
			-- 		})
			-- 	})
			-- end
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
							gitcommit = "[gc]",
						})[entry.source.name]
						return vim_item
					end
				},
				-- the helper builds groups, second group will not
				-- show, while the first one is available
				sources = cmp.config.sources({
					{ name = "gitcommit" },
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
			-- cmp.setup.cmdline(':', {
			-- 	mapping = cmp.mapping.preset.cmdline(),
			-- 	sources = cmp.config.sources({
			-- 		-- 	{ name = 'path' }
			-- 		-- }, {
			-- 		{ name = 'cmdline' }
			-- 	})
			-- })
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
	-- this ensures that mason autoinstalls the mentioned formatters
	{
		"jay-babu/mason-null-ls.nvim",
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
		-- ft = { "python", "javascript", "json", "json5", "lua" },
		dependencies = {
			"williamboman/mason.nvim",
			"jose-elias-alvarez/null-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = nil,
				automatic_installation = false,
			})
		end,
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
					nls.builtins.formatting.isort.with({
						extra_args = { "--profile", "black", "-l", "100" }
					}),
					nls.builtins.formatting.black.with({
						extra_args = { "--line-length", "100" }
					}),
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
			require("which-key").setup({
				window = { border = "rounded" },
			})
			require("core.mappings").std_mappings()
		end,
	},
	-- explorer style tree on the left
	{
		"nvim-tree/nvim-tree.lua",
		lazy = true,
		version = "*",
		event = "BufEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				view = {
					width = 50,
					mappings = {
						list = {
						}
					}
				},
				update_cwd = true,
				update_focused_file = {
					enable = true,
					update_cwd = true,
				},
			})
		end,
	},
	-- terminal buffer, that can be resumed
	{
		"akinsho/toggleterm.nvim",
		lazy = true,
		version = "*",
		cmd = "ToggleTerm",
		dependencies = {
		},
		config = function()
			local default_opts = require("plugins.conf_toggleterm").default_opts
			require("toggleterm").setup(default_opts)
		end,
	},
	-- {
	-- 	"s1n7ax/nvim-terminal",
	-- 	lazy = true,
	-- 	event = "BufEnter",
	-- 	dependencies = {
	-- 	},
	-- 	config = function()
	-- 		require("nvim-terminal").setup({
	-- 			window = {
	-- 				position = "botright",
	-- 				split = "sp",
	-- 				width = 50,
	-- 				height = 15,
	-- 			},
	-- 			disable_default_keymaps = true,
	-- 		})
	-- 	end,
	-- },
	-- fuzzy file finder
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					}
				},
				defaults = {
					mappings = {
						n = {
							["q"] = require('telescope.actions').close,
						},
					},
				},
			})
			require("telescope").load_extension('fzf')
		end,
	},
	-- native fzf integration
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		lazy = true,
		build =
		"cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	},
	-- highlight TODO and other comments
	{
		"folke/todo-comments.nvim",
		lazy = true,
		event = "BufEnter",
		dependencies = {
			"nvim-lua/plenary.nvim"
		},
		config = function()
			require("todo-comments").setup()
		end
	},
	-- zen mode and dimming
	{
		"folke/zen-mode.nvim",
		lazy = true,
		event = "BufEnter",
		dependencies = {
			"folke/twilight.nvim"
		},
		config = function()
			require("zen-mode").setup({
				window = {
					-- width = 0.9,
					width = 120,
				}
			})
		end
	},
	{
		"folke/twilight.nvim",
		lazy = true,
		event = "BufEnter",
		config = function()
			require("twilight").setup({
				dimming = {
					alpha = 0.7,
				}
			})
		end
	},
	-- moves to the project's root dir
	{
		"notjedi/nvim-rooter.lua",
		lazy = true,
		event = "BufEnter",
		config = function()
			require("nvim-rooter").setup({
				rooter_patterns = { ".git", "pyproject.toml" }
			})
		end
	},
	-- keybindings for changing surround quotes, brackets etc.
	{
		"kylechui/nvim-surround",
		lazy = true,
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end
	},
	-- automatic session handling, storing sessions in a dir under .local/share/miro/sessions
	{
		"rmagatti/auto-session",
		lazy = true,
		event = "BufEnter",
		config = function()
			local function restore_nvim_tree()
				local nt = require('nvim-tree.api')
				nt.tree.open()
			end
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "/" },
				auto_session_enabled = true,
				auto_session_create_enabled = true,
				post_restore_cmds = { restore_nvim_tree },
				bypass_session_save_file_types = { "gitcommit", "NvimTree" }
			})
		end
	},
	-- create code images
	{
		"michaelrommel/nvim-silicon",
		lazy = true,
		cmd = "Silicon",
		config = function()
			require("silicon").setup({
				-- Configuration here, or leave empty to use defaults
				theme = "gruvbox",
				to_clipboard = true,
			})
		end
	},
	-- slim tab line
	{
		'michaelrommel/nvim-tabline',
		lazy = true,
		event = "BufEnter",
		dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
		config = function()
			require("tabline").setup({
				show_index = true,
				show_modify = true,
				show_icon = true,
				modify_indicator = ":+",
				no_name = "no name",
				brackets = { "", "" },
				inactive_tab_max_length = 20,
			})
		end
	},
}, lazyopts)
