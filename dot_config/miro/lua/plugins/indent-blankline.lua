-- visually draws vertical lines for code blocks
return {
	"lukas-reineke/indent-blankline.nvim",
	-- commit = "3d08501caef2329aba5121b753e903904088f7e6",
	main = "ibl",
	lazy = true,
	event = "BufEnter",
	opts = {
		indent = {
			tab_char = '▎',
		},
		scope = {
			enabled = true,
			show_start = false,
			show_end = false,
			highlight = "StorageClass"
		}
	}
}
