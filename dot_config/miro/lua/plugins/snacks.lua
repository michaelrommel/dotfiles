return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = false,
			doc = {
				inline = false,
				float = true,
			},
			resolve = function(file, src)
				return file .. "../../../.." .. src
			end
		},
		-- picker = { enabled = true },
		-- bigfile = { enabled = true },
	}
}
