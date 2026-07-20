-- lightweight formatter
return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! targets the active buffer
				vim.b.disable_autoformat = true
				print("Autoformat disabled for this buffer")
			else
				vim.g.disable_autoformat = true
				print("Autoformat disabled globally")
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
			print("Autoformat enabled")
		end, {
			desc = "Re-enable autoformat-on-save",
		})
		local cfm = require("conform")
		cfm.setup({
			formatters_by_ft = {
				python = { "ruff_format", "codespell" },
				javascript = { "prettier", "codespell" },
				json = { "prettier", "codespell" },
				json5 = { "prettier", "codespell" },
				lua = { "stylua" },
				rust = { "rustfmt", "codespell" },
				shell = { "shfmt", "codespell" },
				svelte = { "prettier", "codespell" },
				typescript = { "prettier", "codespell" },
			},
			format_on_save = function(bufnr)
				-- Check global flag or check active buffer flag
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
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
