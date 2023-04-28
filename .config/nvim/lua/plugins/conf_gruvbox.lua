local M = {}

local opts = {
	undercurl = true,
	underline = true,
	bold = true,
	italic = {
		strings = false,
		comments = true,
		operators = false,
		folds = true,
	},
	strikethrough = true,
	invert_selection = false,
	invert_signs = false,
	invert_tabline = false,
	inverse = true, -- invert background for search, diffs, statuslines and errors
	contrast = "hard", -- can be "hard", "soft" or empty string
	palette_overrides = {},
	overrides = {},
	dim_inactive = false,
	transparent_mode = false,
}

M.setup = function ()
	-- setup must be called before loading the colorscheme
	require("gruvbox").setup(opts)
	vim.cmd([[colorscheme gruvbox]])
end

return M
