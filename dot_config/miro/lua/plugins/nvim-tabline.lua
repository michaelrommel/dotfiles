-- slim tab line
return {
	'michaelrommel/nvim-tabline',
	lazy = true,
	event = "BufEnter",
	dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
	opts = {
		show_index = true,
		show_modify = true,
		show_icon = true,
		modify_indicator = "[+]",
		no_name = "no name",
		brackets = { "", "" },
		inactive_tab_max_length = 0,
	},
}
