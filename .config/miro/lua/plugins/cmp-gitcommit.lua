-- a completion engine, that can get suggestions from different sources
return {
	"michaelrommel/cmp-gitcommit",
	lazy = true,
	config = function()
		require("cmp-gitcommit").setup({})
	end,
}
