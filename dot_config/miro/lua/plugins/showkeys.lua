-- show typed keys on screen
local utf8 = require("core.utils").utf8
return {
	"nvzone/showkeys",
	lazy = true,
	event = "BufEnter",
	opts = {
		timeout = 5,
		maxkeys = 8,
		show_count = true,
		winopts = {
			border = "rounded"
		},
		keyformat = {
			["<BS>"] = utf8(0xf006e) .. " ",
			["<CR>"] = utf8(0xf0311),
			["<Space>"] = utf8(0xf1050),
			["<Up>"] = utf8(0xf005d),
			["<Down>"] = utf8(0xf0045),
			["<Left>"] = utf8(0xf004d),
			["<Right>"] = utf8(0xf0054),
			["<PageUp>"] = utf8(0xf013f),
			["<PageDown>"] = utf8(0xf013c),
			["<M>"] = "Alt",
			["<C>"] = "Ctl",
			["<Esc>"] = utf8(0x238b),
		},
	}
}
