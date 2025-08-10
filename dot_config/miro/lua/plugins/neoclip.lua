-- yank manager
return {
	"AckslD/nvim-neoclip.lua",
	lazy = false,
	event = { "BufWritePre" },
	dependencies = {
		{ 'kkharji/sqlite.lua', module = 'sqlite' },
		-- you'll need at least one of these
		-- {'nvim-telescope/telescope.nvim'},
		-- {'ibhagwan/fzf-lua'},
	},
	config = function()
		require('neoclip').setup({
			enable_persistent_history = true,
			continuous_sync = true,
		})
	end,
}
