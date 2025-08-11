-- file explorer in vim
local opts = {
	'stevearc/oil.nvim',
	opts = {
		-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
		-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
		-- Additionally, if it is a string that matches "actions.<name>",
		-- it will use the mapping at require("oil.actions").<name>
		-- Set to `false` to remove a keymap
		-- See :help oil-actions for a list of all available actions
		keymaps = {
			["g?"] = { "actions.show_help", mode = "n" },
			["<CR>"] = "actions.select",
			-- ["<C-v>"] = { "actions.select", opts = { vertical = true } },
			-- ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
			["<C-t>"] = { "actions.select", opts = { tab = true } },
			["<C-p>"] = "actions.preview",
			["<C-l>"] = "actions.refresh",
			-- ["<C-c>"] = { "actions.close", mode = "n" },
			["q"] = { "actions.close", mode = "n" },
			["-"] = { "actions.parent", mode = "n" },
			["_"] = { "actions.open_cwd", mode = "n" },
			-- ["`"] = { "actions.cd", mode = "n" },
			-- ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
			["gs"] = { "actions.change_sort", mode = "n" },
			["gx"] = "actions.open_external",
			["g."] = { "actions.toggle_hidden", mode = "n" },
			["g\\"] = { "actions.toggle_trash", mode = "n" },
		},
		-- Set to false to disable all of the above keymaps
		use_default_keymaps = false,
	},
}
return opts
