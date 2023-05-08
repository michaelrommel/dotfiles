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

local lazyopts = require("configs.conf_lazy").opts
-- local overrides = require("custom.plugins").overrides
-- local dump = require("core.utils").dump

-- local plugins = vim.tbl_deep_extend(
-- 	"force",
-- 	default_plugins,
-- 	overrides or {}
-- )
-- vim.notify(dump(plugins), vim.log.levels.info)

-- load theme icons
require("core.theme")

-- lazy load now all plugins
require("lazy").setup("plugins", lazyopts)

-- load all key mappings
require("core.mappings")

-- vim: sw=4:ts=4
