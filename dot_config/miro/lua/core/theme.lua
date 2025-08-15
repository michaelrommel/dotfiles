local M = {}

local utf8 = require("core.utils").utf8

-- Change diagnostic signs to be consistent with defaults from nvim-lualine
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = utf8(0xf659),
			[vim.diagnostic.severity.WARN] = utf8(0xf529),
			[vim.diagnostic.severity.INFO] = utf8(0xf7fc),
			[vim.diagnostic.severity.HINT] = utf8(0xf835),
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = 'DiagnosticError',
			[vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
			[vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
			[vim.diagnostic.severity.HINT] = 'DiagnosticHint',

		},
	},
	-- float = { border = "rounded" },
	virtual_text = {
		current_line = true,
		prefix = utf8(0x25cf)
	},
	virtual_lines = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Diagnostic popup
vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#151819]]
vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#151819]]
-- vim.cmd([[highlight link FloatBorder NormalFloat]])

-- disable semantic token highlights from the language servers
-- they have higher prio than treesitter, but currently are less
-- granular and override custom captures
-- vim.api.nvim_create_autocmd('Colorscheme', {
-- 	callback = function()
-- 		for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
-- 			vim.api.nvim_set_hl(0, group, {})
-- 		end
-- 	end
-- })

-- define here, that removes lspkind as another module
M.icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "塞",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = ""
}

return M
