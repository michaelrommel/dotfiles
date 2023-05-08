-- autoinstaller for language servers' configurations
return {
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

		local on_attach = require("configs.conf_lsp").on_attach

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
}
