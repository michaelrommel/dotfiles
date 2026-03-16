-- rendering plugin for markdown et. al.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "markdown" },
	opts = {
		file_types = { "markdown" },
		bullet = {
			icons = { "●", "○", "◆", "◇" },
		},
		checkbox = {
			unchecked = {
				icon = " ",
				highlight = "RenderMarkdownUnchecked",
				scope_highlight = nil,
			},
			checked = {
				icon = " ",
				highlight = "RenderMarkdownChecked",
				scope_highlight = "@markup.strikethrough",
			},
		},
		link = {
			footnote = {
				superscript = false,
			},
		},
	},
}
