vim.cmd("syntax off")

vim.opt.winborder = "rounded"
vim.opt.hlsearch = true
vim.opt.tabstop = 4
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes:1"
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = '~' }
vim.opt.list = true
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.autoindent = true
vim.opt.showbreak = " 󱞪 "
vim.opt.formatoptions = "jcro/qnp"

-- treat zsh like bash
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.sh", "*.zsh" },
	command = "silent! set filetype=sh",
})

vim.g.mapleader = " "

vim.keymap.del('n', 'Y')
local map = vim.keymap.set
map('n', '<leader>v', ':e $MYVIMRC<CR>')
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<leader>cd', ':colorscheme default<CR>')
map('n', '<leader>cg', ':colorscheme gruvbox<CR>')
map('n', '<leader>cl', ':colorscheme lunaperche<CR>')
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>d', '"+d')
map({ 'n', 'v' }, '<leader>c', '1z=')

vim.pack.add({
	{ src = "https://github.com/michaelrommel/gruvbox.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = "https://github.com/mason-org/mason.nvim" },
})

require("gruvbox").setup({
	italic = {
		strings = false,
		comments = true,
		folds = true,
	},
	contrast = "hard",
}) -- vim.cmd("colorscheme gruvbox")
vim.cmd(":hi statusline guibg=#666666 guifg=White")

require("mason").setup()
require("oil").setup()
map('n', '-', function() require("oil").open_float() end)
require("conform").setup({
	formatters_by_ft = {
		python = { "ruff_format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
require('nvim-treesitter').setup({
	highlight = { enable = true, },
})
require("nvim-treesitter").install { 'lua', 'python' }
require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' },
			},
		},
	},
})
vim.lsp.enable({ "lua_ls", "jedi_language_server", "ruff" })
vim.diagnostic.config({ virtual_text = true })
