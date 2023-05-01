local M = {}

local utf8 = require("core.utils").utf8
local fn = vim.fn

-- Change diagnostic signs to be consistent with defaults from nvim-lualine
fn.sign_define("DiagnosticSignError", { text = utf8(0xf659), texthl = "DiagnosticSignError" })
fn.sign_define("DiagnosticSignWarn", { text = utf8(0xf529), texthl = "DiagnosticSignWarn" })
fn.sign_define("DiagnosticSignInformation", { text = utf8(0xf7fc), texthl = "DiagnosticSignInfo" })
fn.sign_define("DiagnosticSignHint", { text = utf8(0xf835), texthl = "DiagnosticSignHint" })

-- Diagnostic popup
vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1d2021]]
vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1d2021]]
-- vim.cmd([[highlight link FloatBorder NormalFloat]])

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
