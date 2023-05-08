local fn = vim.fn
local icons = require("core.theme").icons

return {
	"hrsh7th/nvim-cmp",
	lazy = true,
	version = false,
	event = "InsertEnter",
	dependencies = {
		-- get suggestions from language servers
		"hrsh7th/cmp-nvim-lsp",
		-- get text fragments from current buffer, mostly sensible for
		-- markdown texts or so
		"hrsh7th/cmp-buffer",
		-- can suggest filenames from the local filesystem
		"hrsh7th/cmp-path",
		-- provides vim commandline completions
		"hrsh7th/cmp-cmdline",
		-- completions for the nvim lua api
		"hrsh7th/cmp-nvim-lua",
		-- vsips provider
		"hrsh7th/cmp-vsnip",
		"hrsh7th/vim-vsnip",
		"michaelrommel/cmp-gitcommit",
	},
	config = function()
		local cmp = require("cmp")
		local cmp_mappings = require("core.mappings").cmp_mappings()
		-- print("registring autocommand")
		-- if vim.bo.filetype == "gitcommit" then
		-- 	cmp.setup.buffer({
		-- 		sources = cmp.config.sources({
		-- 			{ name = "conventionalcommits" }
		-- 		}, {
		-- 			{ name = "buffer" }
		-- 		})
		-- 	})
		-- end
		cmp.setup({
			experimental = {
				ghost_text = { hl_group = 'Comment' }
			},
			completion = {
				autocomplete = false,
			},
			preselect = cmp.PreselectMode.None,
			snippet = {
				expand = function(args)
					fn["vsnip#anonymous"](args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			formatting = {
				format = function(entry, vim_item)
					-- print(string.format("%s -> %s", entry.source.name, vim_item))
					if vim.tbl_contains({ 'path' }, entry.source.name) then
						local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item()
							.label)
						if icon then
							vim_item.kind = string.format('%s %s', icon, vim_item.kind)
							vim_item.kind_hl_group = hl_group
						end
					else
						vim_item.kind = string.format('%s %s', icons[vim_item.kind], vim_item.kind)
					end
					vim_item.menu = ({
						buffer = "[buf]",
						nvim_lsp = "[lsp]",
						luasnip = "[lsnip]",
						vsnip = "[vsnip]",
						nvim_lua = "[lua]",
						gitcommit = "[gc]",
					})[entry.source.name]
					return vim_item
				end
			},
			-- the helper builds groups, second group will not
			-- show, while the first one is available
			sources = cmp.config.sources({
				{ name = "gitcommit" },
				{ name = 'vsnip' },
				{ name = 'nvim_lsp' },
				{ name = 'path' },
			}, {
				{ name = "buffer" }
			}),
			mapping = cmp.mapping.preset.insert(cmp_mappings),
		})
		cmp.setup.cmdline('/', {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = 'buffer' }
			}
		})
		-- cmp.setup.cmdline(':', {
		-- 	mapping = cmp.mapping.preset.cmdline(),
		-- 	sources = cmp.config.sources({
		-- 		-- 	{ name = 'path' }
		-- 		-- }, {
		-- 		{ name = 'cmdline' }
		-- 	})
		-- })
	end,
}
