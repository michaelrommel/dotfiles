local M = {}
local merge_tb = vim.tbl_deep_extend

M.default_opts = {
	start_in_insert = true,
	hide_numbers = true,
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	float_opts = {
		border = "rounded",
		width = function()
			return math.ceil(vim.o.columns * 0.7)
		end,
		height = function()
			return math.ceil(vim.o.lines * 0.7)
		end,
	},
}

M.floatterm_opts = {
	hidden = true,
	direction = "float",
}

M.miniterm_opts = merge_tb(
	"force",
	M.floatterm_opts,
	{
		float_opts = {
			width = function()
				return math.min(80, vim.o.columns - 2)
			end,
			col = function()
				if vim.o.columns > 82 then
					return vim.o.columns - 82
				else
					return 0
				end
			end,
			height = function()
				return math.min(24, vim.o.lines - 4)
			end,
			row = function()
				if vim.o.lines > 28 then
					return vim.o.lines - 28
				else
					return 0
				end
			end,
		}
	}
)

return M
