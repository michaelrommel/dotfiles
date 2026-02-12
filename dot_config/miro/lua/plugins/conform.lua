-- lightweight formatter
return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		local cfm = require("conform")
		cfm.setup({
			formatters_by_ft = {
				python = { "ruff_format" },
				javascript = { "prettier" },
				json = { "prettier" },
				json5 = { "prettier" },
				shell = { "shfmt" },
				rust = { "rustfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
			formatters = {
				shfmt = {
					prepend_args = { "-i", "4" },
				},
				rustfmt = {
					-- prepend_args = { "--edition", "2021" }
				},
				prettier = {
					ft_parsers = {
						json = "json",
						jsonc = "json",
						json5 = "json",
					},
				},
			},
			log_level = vim.log.levels.DEBUG,
			notify_on_error = false,
		})
		local prettier = require("conform.formatters.prettier")
		local default_args_func = prettier.args
		prettier.args = function(self, ctx)
			local default_args = default_args_func(self, ctx)
			local ft = vim.bo[ctx.buf].filetype
			if ft == "json5" then
				local newargs = vim.list_extend(default_args, { "--use-tabs", "--quote-props", "preserve" })
				return newargs
			else
				local newargs = vim.list_extend(
					default_args,
					{ "--use-tabs", "--semi", "--single-quote", "--trailing-comma", "none" }
				)
				return newargs
			end
		end
	end,
}
