-- lightweight formatter
return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		Dump = function(t)
			local conv = {
				["nil"] = function() return "nil" end,
				["number"] = function(n) return tostring(n) end,
				["string"] = function(s) return '"' .. s .. '"' end,
				["boolean"] = function(b) return tostring(b) end
			}
			if type(t) == "table" then
				local s = "{"
				for k, v in pairs(t) do
					if type(v) == "table" then
						s = s .. (s == "{" and " " or ", ") .. (k .. " = " .. Dump(v))
					else
						s = s .. (s == "{" and " " or ", ") .. k .. " = " .. conv[type(v)](v)
					end
				end
				return s .. " }"
			else
				return conv[type(t)](t)
			end
		end

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
					prepend_args = { "-i", "4" }
				},
				rustfmt = {
					prepend_args = { "--edition", "2021" }
				},
				prettier = {
					ft_parsers = {
						json = "json",
						jsonc = "json",
						json5 = "json",
					}
				}
			},
			log_level = vim.log.levels.DEBUG,
			notify_on_error = false
		})
		local prettier = require("conform.formatters.prettier")
		local default_args_func = prettier.args
		cfm.formatters.prettier.args = function(self, ctx)
			local default_args = default_args_func(self, ctx)
			local ft = vim.bo[ctx.buf].filetype
			if ft == "json5" then
				local newargs = vim.list_extend(default_args,
					{ "--use-tabs", "--quote-props", "preserve" }
				)
				return newargs
			else
				local newargs = vim.list_extend(default_args,
					{ "--use-tabs", "--semi", "--single-quote", "--trailing-comma", "none" }
				)
				return newargs
			end
		end
		-- local default_range_args = cfm.formatters.prettier.range_args
		-- cfm.formatters.prettier.range_args = function(self, ctx)
		-- 	local ft = vim.bo[ctx.buf].filetype
		-- 	if ft == "json5" then
		-- 		return vim.list_extend(default_range_args,
		-- 			{ "--use-tabs", "--quote-props", "preserve" })
		-- 	else
		-- 		return vim.list_extend(default_range_args,
		-- 			{ "--use-tabs", "--semi", "--single-quote", "--trailing-comma none" })
		-- 	end
		-- end
	end
}
