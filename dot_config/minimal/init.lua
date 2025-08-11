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
vim.opt.listchars = { tab = utf8(0xBB) .. ' ', trail = utf8(0xB7), nbsp = '~' }
vim.opt.list = true
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.autoindent = true
vim.opt.showbreak = " " .. utf8(0xf17aa) .. " "
vim.opt.formatoptions = "jcro/qnp"

-- treat zsh like bash
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.sh", "*.zsh" },
	command = "silent! set filetype=sh",
})

vim.g.mapleader = " "

-- remove the default mapping of Y to y$
vim.keymap.del('n', 'Y')

local map = vim.keymap.set
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<leader>v', ':e $MYVIMRC<CR>')
-- map('n', '<leader>s', ':e #<CR>')
-- map('n', '<leader>S', ':sf #<CR>')
-- map('n', '<leader>lf', vim.lsp.buf.format)
-- map({ 'n', 'v' }, '<leader>y', '"+y')
-- map({ 'n', 'v' }, '<leader>d', '"+d')
-- map({ 'n', 'v' }, '<leader>c', '1z=')

vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = "https://github.com/mason-org/mason.nvim" },
})

require "mason".setup()
require "oil".setup()

vim.lsp.enable({ "lua_ls", "python" })
require('nvim-treesitter.configs').setup({ highlight = { enable = true, }, })

