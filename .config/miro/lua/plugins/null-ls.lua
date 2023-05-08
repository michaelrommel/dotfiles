-- fallback language server, that can use external programs for linting
-- and autoformatting
return {
	"jose-elias-alvarez/null-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		-- asynchronous lib for lua
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local nls = require("null-ls")
		local on_attach = require("configs.conf_lsp").on_attach
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
}
