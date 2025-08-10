-- plugin for opening documentation links in browsers
return {
	"lalitmee/browse.nvim",
	lazy = true,
	event = "BufEnter",
	-- dependencies = { "nvim-telescope/telescope.nvim" },
	opts = {
		-- search provider you want to use
		provider = "google",
		-- either pass it here or just pass the table to the functions
		-- see below for more
		bookmarks = {}
	}
}
