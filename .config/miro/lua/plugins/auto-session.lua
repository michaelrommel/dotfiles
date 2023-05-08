-- automatic session handling, storing sessions in a dir under .local/share/miro/sessions
return {
	"rmagatti/auto-session",
	lazy = true,
	event = "BufEnter",
	config = function()
		local function restore_nvim_tree()
			local nt = require('nvim-tree.api')
			nt.tree.open()
		end
		require("auto-session").setup({
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "/" },
			auto_session_enabled = true,
			auto_session_create_enabled = true,
			post_restore_cmds = { restore_nvim_tree },
			bypass_session_save_file_types = { "gitcommit", "NvimTree" }
		})
	end
}
