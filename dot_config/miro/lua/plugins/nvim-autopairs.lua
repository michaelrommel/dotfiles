-- this automatically inserts closing quotes or brackets
return {
	"windwp/nvim-autopairs",
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("nvim-autopairs").setup({
			fast_wrap = {
				map = '<C-q>',
				chars = { '{', '[', '(', '"', "'" },
				pattern = [=[[%'%"%>%]%)%}%,%;]]=],
				end_key = '$',
				before_key = 'h',
				after_key = 'l',
				cursor_pos_before = true,
				avoid_move_to_end = false,
				keys = 'qwertyuiopzxcvbnmasdfghjkl',
				manual_position = false,
				highlight = 'Search',
				highlight_grey = 'Comment'
			},
		})
	end
}
