utf8 = function(decimal)
	local bytemarkers = { { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } }
	if decimal < 128 then return string.char(decimal) end
	local charbytes = {}
	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local mod = decimal % 64
				decimal = (decimal - mod) / 64
				charbytes[b] = string.char(128 + mod)
			end
			charbytes[1] = string.char(vals[2] + decimal)
			break
		end
	end
	return table.concat(charbytes)
end

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
map('n', '<leader>v', ':e $MYVIMRC<CR>')
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>d', '"+d')
map({ 'n', 'v' }, '<leader>c', '1z=')

vim.pack.add({
	{ src = "https://github.com/projekt0n/github-nvim-theme" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = "https://github.com/mason-org/mason.nvim" },
})

require("github-theme").setup({
	options = {
		styles = {
			comments = "italic",
			functions = "bold",
		}
	}
})
vim.cmd("colorscheme github_dark_high_contrast")
vim.cmd(":hi statusline guibg=#666666 guifg=White")

require "mason".setup()
local oil = require "oil"
oil.setup()
map('n', '-', function() oil.open_float() end)

require('nvim-treesitter').setup({ 
	 -- Directory to install parsers and queries to
	install_dir = vim.fn.stdpath('data') .. '/site',
	highlight = { enable = true, },
})
require'nvim-treesitter'.install { 'lua', 'python' }

vim.lsp.enable({ "lua_ls", "jedi_language_server" })

vim.diagnostic.config({ virtual_text = true })
