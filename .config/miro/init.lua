require("core")

-- initialize lazy loader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable", -- latest stable release
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- load theme icons
require("core.theme")

-- lazy load now all plugins
local lazyopts = require("configs.conf_lazy").opts
require("lazy").setup("plugins", lazyopts)

-- load all key mappings
require("core.mappings")

-- vim: sw=4:ts=4
