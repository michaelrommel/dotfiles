local utf8 = require("core.utils").utf8
local is_wsl = require("core.utils").is_wsl

local opt = vim.opt
local g = vim.g

-- this is the standard leader for neovim in many configurations
-- it is the only keymapping we set here, because this needs to be
-- sourced before the plugin manager
g.mapleader = " "

-- if in WSL, we set a clipboard provider mainly for calling a script
-- for pasting from the Windows clipboard. Copying onto it, is done
-- by the smartyank lua plugin
if is_wsl then
	g.clipboard = {
		name = 'WSLClipboard',
		copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
		paste = { ["+"] = { "nvim_paste.sh" }, ["*"] = { "nvim_paste.sh" } },
		cache_enabled = true
	}
end

-- turn off syntax, as we have treesitter highlighting or
-- alternatively the lsp semantic tokens
vim.cmd("syntax off")

-- This enables 24 bit aka Truecolor. Also switches to using guifg
-- attributes instead of cterm attributes:
opt.termguicolors = true
-- show the linenumbers to the left of the source code
opt.number = true
-- and show relativenumbers above/below the current line
opt.relativenumber = true
-- always show the signcolumn for git status and errors
opt.signcolumn = "yes:1"
-- globally set new border
opt.winborder = "rounded"
-- display certain invisible characters
opt.listchars = { tab = utf8(0xBB) .. ' ', trail = utf8(0xB7), nbsp = '~' }
opt.list = true
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
-- opt.clipboard = "unnamedplus"
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
opt.autoindent = true
opt.showbreak = " " .. utf8(0x2937) .. " "
-- set max syntax highlighting column, after that syntax is off
opt.synmaxcol = 240
-- show max width of text
opt.colorcolumn = "101"
-- formatting
-- j: compress comment leaders when joining lines
-- c: autowrap with comments
-- r: comments after return/enter
-- o: insert comment leader with o/O
-- /: only insert comment leader when on start of the line
-- q: comment formatting with gq
-- n: recognize numbered lists
-- p: prose feature, do not break line after dot space
opt.formatoptions = "jcro/qnp"
-- set sessionoptions for compatibility with auto-session
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
-- these options are necessary for which-key as well
opt.timeout = true
opt.timeoutlen = 500
-- set title string of the terminal. :~ modifier tries to make path relative to HOME
opt.title = true
opt.titlestring = "%.20t%( (%.30{expand(\"%:~:h\")})%)"
-- for minimal tabline
opt.showtabline = 2

-- treat zsh like bash
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.sh", "*.zsh" },
	command = "silent! set filetype=sh",
})

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
