-- this extends the builtin treesitter and autoloads additional language
-- grammars when a buffer is opened
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects"
	},
	event = { "BufEnter", "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	-- build = function()
	-- 	require("nvim-treesitter.install").update({ with_sync = true })
	-- end,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = true,
			auto_install = true,
			highlight = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-n>",
					node_incremental = "<C-n>",
					scope_incremental = false,
					node_decremental = "<bs>"
				}
			}
		})
	end
}
