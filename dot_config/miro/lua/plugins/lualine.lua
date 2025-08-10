-- bare necessities statusline in vim, shows git status, filetype, encoding
-- and cursor position without much configuration
return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	config = function()
		local function active_lsps()
			local filetype = vim.bo.filetype
			local bufnr = vim.api.nvim_get_current_buf()
			local clients = vim.lsp.get_clients()
			local clients_list = {}
			for _, client in pairs(clients) do
				local filetypes = client.config.filetypes or {}
				for _, ft in pairs(filetypes) do
					if ft == filetype and client.attached_buffers[bufnr] then
						table.insert(clients_list, string.sub(client.name, 1, 3))
					end
				end
			end
			return #clients_list > 0 and "-" .. table.concat(clients_list, ",") .. " " or " "
		end

		require("lualine").setup({
			options = {
				ignore_focus = {
					"neo-tree",
				}
			},
			sections = {
				lualine_b = {
					{ 'branch', icon = '\u{f062c}' },
					'diff',
					'diagnostics'
				},
				lualine_x = {
					'encoding',
					{ 'fileformat', padding = { left = 0, right = 1 } },
					{ 'filetype',   padding = { left = 1, right = 0 }, separator = "", },
					{ active_lsps,  padding = { left = 0, right = 0 } },
				},
				lualine_y = { "searchcount", "selectioncount", "progress" }
			}
		})
	end,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	}
}
