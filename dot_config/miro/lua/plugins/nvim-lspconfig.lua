-- config for language servers
return {
	"neovim/nvim-lspconfig",
	lazy = true,
	ft = {
		"sh",
		"bash",
		"zsh",
		"css",
		"gitcommit",
		"graphql",
		"html",
		"javascript",
		"json",
		"json5",
		"lua",
		"markdown",
		"python",
		"rust",
		"svelte",
		"text",
	},
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"saghen/blink.cmp",
		"aznhe21/actions-preview.nvim",
		-- separates the update intervals of lsp from autosaved files/buffers
		"antoinemadec/FixCursorHold.nvim",
	},
	config = function()
		-- set up border around the LspInfo window
		require("lspconfig.ui.windows").default_options.border = "rounded"
		-- set the time before a lsp hover window appears
		vim.g.cursorhold_updatetime = 500
		-- set up generic handlers and capabilities
		local on_attach = require("configs.conf_lsp").on_attach
		local capabilities = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities(),
			require("blink.cmp").get_lsp_capabilities({}, false)
		)
		-- set up utility functions
		local function _suppress(diag, codes)
			-- jsonls doesn't really support json5
			-- remove some annoying errors
			for _, v in pairs(codes) do
				local idx = 1
				while diag ~= nil and idx <= #diag do
					if diag[idx].code == v then
						print("suppressing: " .. idx .. "-" .. diag[idx].code)
						table.remove(diag, idx)
					else
						idx = idx + 1
					end
				end
			end
		end
		-- now set up all language servers
		vim.lsp.config("bacon-ls", {
			filetypes = { "rust" },
			root_markers = { "Cargo.toml", "rust-project.json" },
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("bashls", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "sh", "bash", "zsh" },
		})
		vim.lsp.config("cssls", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "css" },
			settings = {
				css = {
					-- customData = {
					-- 	"/tmp/tailwind.css-data.json"
					-- },
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})
		vim.lsp.config("eslint", {
			on_attach = on_attach,
			capabilities = capabilities,
			root_markers = { "package.json", "eslint.config.*" },
		})
		vim.lsp.config("harper_ls", {
			filetypes = { "markdown", "gitcommit", "text" },
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				["harper-ls"] = {
					userDictPath = os.getenv("HOME") .. "/.config/harper-ls/dictionary.txt",
					fileDictPath = os.getenv("HOME") .. "/.config/harper-ls/file_dictionaries",
					linters = {
						Dashes = false,
						SpellCheck = true,
						SpelledNumbers = false,
						SentenceCapitalization = false,
						WrongQuotes = false,
						ToDoHyphen = false,
					},
					codeActions = {
						ForceStable = false,
					},
					markdown = {
						IgnoreLinkTitle = false,
					},
					diagnosticSeverity = "hint",
					isolateEnglish = false,
					dialect = "British",
				},
			},
		})
		vim.lsp.config("jsonls", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "json", "jsonc", "json5" },
			init_options = {
				provideFormatter = false,
			},
			handlers = {
				-- this is the push handling of diagnostics information
				["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
					if string.match(result.uri, "%.json5$", -6) and result.diagnostics ~= nil then
						-- 519: "Trailing comma""
						-- 521: "Comments are not permitted in JSON."
						_suppress(result.diagnostics, { 519, 521 })
					end
					vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
				end,
				-- this is the pull diagnostics method, in spec since 3.17.0
				["textDocument/diagnostic"] = function(err, result, ctx, config)
					local extension =
						vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":e")
					if string.match(extension, "json5$", -6) and result.items ~= nil then
						_suppress(result.items, { 521, 519 })
					end
					vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
				end,
			},
		})
		vim.lsp.config("lua_ls", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "lua" },
			settings = {
				Lua = {
					diagnostics = {
						-- Get the language server to recognize the `vim` global
						globals = { "vim" },
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
		local ra_capabilities = vim.tbl_deep_extend("force", capabilities, {
			general = {
				positionEncodings = { "utf-16" },
			},
		})
		vim.lsp.config("rust_analyzer", {
			on_attach = on_attach,
			capabilities = ra_capabilities,
			filetypes = { "rust" },
			cmd = { "rust-analyzer" },
			settings = {
				["rust-analyzer"] = {
					diagnostics = {
						enable = true,
					},
				},
			},
		})
		-- 	single_file_suport = true,
		-- 	settings = {
		-- 		["rust-analyzer"] = {
		-- 			diagnostics = {
		-- 				enable = true,
		-- 			},
		-- 			cargo = {
		-- 				allFeatures = true,
		-- 				buildScripts = {
		-- 					enable = true,
		-- 				},
		-- 			},
		-- 			checkOnSave = {
		-- 				enable = true,
		-- 				allFeatures = true,
		-- 				overrideCommand = {
		-- 					"cargo",
		-- 					"clippy",
		-- 					"--workspace",
		-- 					"--message-format=json",
		-- 					"--all-targets",
		-- 					"--all-features",
		-- 				},
		-- 			},
		-- 		},
		-- 	},
		-- })
		vim.lsp.config("codelldb", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("ruff", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("svelte", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("tailwindcss", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("ts_ls", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("graphql", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("html", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("jedi_language_server", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("js-debug-adapter", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("prettier", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("shellcheck", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("shfmt", {
			on_attach = on_attach,
			capabilities = capabilities,
		})
		vim.lsp.config("", {
			on_attach = on_attach,
			capabilities = capabilities,
		})

		-- finally we can start the servers, if they are
		-- installed and ready
		local mmt = require("core.utils").make_mason_mapping_table
		local isi = require("core.utils").is_lsp_installed
		-- this is verbatim from mason-tool-installer
		local ensure_installed = {
			"bacon-ls",
			"rust_analyzer",
			"bash-language-server",
			"codelldb",
			"css-lsp",
			"eslint-lsp",
			"graphql-language-service-cli",
			"harper-ls",
			"html-lsp",
			"jedi-language-server",
			"js-debug-adapter",
			"json-lsp",
			"lua-language-server",
			"prettier",
			"ruff",
			"shellcheck",
			"shfmt",
			"stylua",
			"svelte-language-server",
			"tailwindcss-language-server",
			"typescript-language-server",
		}
		local mapping_table = mmt()
		for _, server in ipairs(ensure_installed) do
			-- print("checking: " .. server)
			if isi(server) then
				-- local mapped = mapping_table[server] or ""
				-- print("enabling: " .. server .. "(" .. mapped .. ")")
				if mapping_table[server] then
					vim.lsp.enable({ mapping_table[server] })
				else
					vim.lsp.enable({ server })
				end
			end
		end
		local non_mason = {
			"rust_analyzer",
		}
		for _, server in ipairs(non_mason) do
			-- print("checking: " .. server)
			if vim.fn.executable("rg") == 1 then
				vim.lsp.enable({ server })
			end
		end
	end,
}
