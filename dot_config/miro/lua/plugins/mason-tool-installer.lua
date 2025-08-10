-- an installer for tools for linters, formatters
return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = {
		"williamboman/mason.nvim",
	},
	lazy = true,
	config = function()
		require('mason').setup({})
		vim.api.nvim_create_autocmd('User', {
			pattern = 'MasonToolsStartingInstall',
			callback = function()
				vim.schedule(function()
					print 'mason-tool-installer starting...'
				end)
			end,
		})
		vim.api.nvim_create_autocmd('User', {
			pattern = 'MasonToolsUpdateCompleted',
			callback = function(e)
				vim.schedule(function()
					print("mason-tool-installer finished.")
					-- print(vim.inspect(e.data)) -- print the table that lists the programs that were installed
				end)
			end,
		})
		require("mason-tool-installer").setup({
			-- language servers go into mason-lspconfig
			ensure_installed = {
				"bacon",
				"bacon-ls",
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
			},
			-- if set to true this will check each tool for updates. If updates
			-- are available the tool will be updated. This setting does not
			-- affect :MasonToolsUpdate or :MasonToolsInstall.
			-- Default: false
			auto_update = true,

			-- automatically install / update on startup. If set to false nothing
			-- will happen on startup. You can use :MasonToolsInstall or
			-- :MasonToolsUpdate to install tools and check for updates.
			-- Default: true
			run_on_start = true,

			-- set a delay (in ms) before the installation starts. This is only
			-- effective if run_on_start is set to true.
			-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
			-- Default: 0
			start_delay = 500, -- 0.5 second delay

			-- Only attempt to install if 'debounce_hours' number of hours has
			-- elapsed since the last time Neovim was started. This stores a
			-- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
			-- This is only relevant when you are using 'run_on_start'. It has no
			-- effect when running manually via ':MasonToolsInstall' etc....
			-- Default: nil
			debounce_hours = 5, -- at least 5 hours between attempts to install/update
		})
	end
}
