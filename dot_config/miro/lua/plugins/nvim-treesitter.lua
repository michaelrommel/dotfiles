-- this extends the builtin treesitter and autoloads additional language
-- grammars when a buffer is opened
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects"
	},
	event = { "BufEnter", "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	-- build = function()
	-- 	require("nvim-treesitter.install").update({ with_sync = true })
	-- end,
	config = function()
		require("nvim-treesitter").install({ "c", "lua", "vim", "vimdoc", "query",
			"python", "rust", "javascript", "markdown" })
		vim.api.nvim_create_autocmd('FileType', {
			pattern = { "*" },
			callback = function()
				local ok, parser = pcall(vim.treesitter.get_parser, 0, vim.bo.filetype)
				if ok and parser ~= nil then
					vim.treesitter.start()
				end
			end,
		})
	end
}
