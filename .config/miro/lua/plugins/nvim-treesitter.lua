-- this extends the builtin treesitter and autoloads additional language
-- grammars when a buffer is opened
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	event = "BufEnter",
	build = function()
		require("nvim-treesitter.install").update({ with_sync = true })
	end,
	opt = {
		-- ensure_installed = { "c", "lua", "query", "vim", "vimdoc"}
		-- ensure_installed = { "bash", "cpp", "css", "diff", "dockerfile", "gitcommit", "gitignore", "go", "graphql", "html", "http", "ini", "javascript", "jq", "jsdoc", "json", "jsonc", "json5", "make", "markdown", "mermaid", "python", "regex", "rust", "svelte", "toml", "yaml" },
		auto_install = true,
		highlight = {
			enable = true,
		}
	}
}
