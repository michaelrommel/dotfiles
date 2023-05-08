local utf8 = require("core.utils").utf8

local opt = vim.opt
local g = vim.g

-- this is the standard leader for neovim in many configurations
-- it is the only keymapping we set here, because this needs to be
-- sourced before the plugin manager
vim.g.mapleader = " "

-- This enables 24 bit aka Truecolor. Also switches to using guifg
-- attributes instead of cterm attributes:
opt.termguicolors = true
-- show the linenumbers to the left of the source code
opt.number = true
-- and show relativenumbers above/below the current line
opt.relativenumber = true
-- always show the signcolumn for git status and errors
opt.signcolumn = "yes:1"
-- display certain invisible characters
opt.listchars = { tab = utf8(0xBB) .. ' ', trail = utf8(0xB7), nbsp = '~' }
opt.list = true
-- show max width of text
opt.colorcolumn = "101"
-- disable showing the vim mode in the statusline
opt.showmode = false
-- do not expand tabs to spaces and configure tabs
opt.expandtab = false
opt.shiftwidth = 4
opt.tabstop = 4
-- set mouse to auto
opt.mouse = "a"
-- no standard ruler, the statusline takes care of that
opt.ruler = false
-- new windows appear on the right and below the current window
opt.splitright = true
opt.splitbelow = true
opt.equalalways = true
-- use the clipboard instead of registers
opt.clipboard = "unnamedplus"
-- keep an undo file
opt.undofile = true
-- show autocomplete menu always, do not autoselect an entry and
-- do not insert anything automatically
opt.completeopt = "menuone,noinsert,noselect"
-- fold with markers
opt.foldmethod = "marker"
-- we can break long lines in wrap mode without inserting a <EOL>
opt.linebreak = true
opt.breakindent = true
opt.showbreak = " " .. utf8(0xf17aa) .. " "
-- set max syntax highlighting column, after that syntax is off
opt.synmaxcol = 240
-- set sessionoptions for compatibility with auto-session
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
-- these options are necessary for which-key as well
opt.timeout = true
opt.timeoutlen = 500
-- for minimal tabline
opt.showtabline = 2

-- disable some default providers
for _, provider in ipairs { "node", "perl", "ruby" } do
	g["loaded_" .. provider .. "_provider"] = 0
end

-- disable some builtin plugins
local disabled_built_ins = {
	"2html_plugin",
	"getscript",
	"getscriptPlugin",
	"gzip",
	"logipat",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"matchit",
	"tar",
	"tarPlugin",
	"rrhelper",
	"spellfile_plugin",
	"vimball",
	"vimballPlugin",
	"zip",
	"zipPlugin",
	"tutor",
	"rplugin",
	"synmenu",
	"optwin",
	"compiler",
	"bugreport",
	"ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
	g["loaded_" .. plugin] = 1
end

-- vim: sw=4:ts=4
