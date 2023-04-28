local opts = require("plugins.conf_lazy").opts
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
					require("plugins.conf_gruvbox").setup()
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
			require("plugins.conf_dap").setup()
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
		config = function()
			require("mini.pairs").setup()
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
			local feedkey = function(key, mode)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
			end
			cmp.setup({
				snippet = {
					expand = function(args)
						-- luasnip.lsp_expand(args.body)
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
						elseif fn["vsnip#available"](1) == 1 then
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
						elseif fn["vsnip#available"](-1) == 1 then
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
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local nls = require("null-ls")
			local on_attach = require("plugins.conf_lsp").on_attach
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
}, opts)
