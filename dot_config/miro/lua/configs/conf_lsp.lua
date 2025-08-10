local M = {}

local deprecatedFormatters = { "ts_ls", "jsonls" }
local utf8 = require("core.utils").utf8

-- needs to be a global to be used also as formatexpr
function LspRangeFormat()
	local range = {
		['start'] = { row = vim.v.lnum, col = 0 },
		['end'] = { row = vim.v.lnum + vim.v.count, col = 0 },
	}
	vim.lsp.buf.format({ range = range })
end

-- needs to be a global to be used also as formatexpr
function LspFormat(bufnr)
	vim.lsp.buf.format({
		-- filter = function(client)
		-- 	local deprecated = false
		-- 	for _, n in ipairs(deprecatedFormatters) do
		-- 		deprecated = deprecated or client.name == n
		-- 	end
		-- 	if not deprecated then
		-- 		print(client.name)
		-- 	end
		-- 	return not deprecated
		-- end,
		bufnr = bufnr,
	})
end

M.on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- disable the semantic tokens
	-- client.server_capabilities.semanticTokensProvider = nil

	-- print(string.format("%s -> %s/%s", client.name,client.server_capabilities.documentFormattingProvider, client.server_capabilities.documentRangeFormattingProvider))
	if client:supports_method("textDocument/formatting") then
		local deprecated = false
		for _, n in ipairs(deprecatedFormatters) do
			local _, _, c, f = string.find(n, '(.*)/(.*)')
			if c then
				-- there was a complex combination given
				deprecated = deprecated or (client.name == c and f == vim.bo.filetype)
			else
				deprecated = deprecated or client.name == n
			end
		end
		if deprecated then
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		else
			local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					LspFormat(bufnr)
				end,
			})
			-- we can use the lsp formatter also for gq commands
			if client:supports_method("textDocument/rangeFormatting") then
				-- print(client.name .. " can range format")
				vim.api.nvim_buf_set_option(bufnr, "formatexpr", 'v:lua.LspRangeFormat()')
			else
				-- print(client.name .. " cannot range format")
				vim.api.nvim_buf_set_option(bufnr, "formatexpr", 'v:lua.LspFormat()')
			end
		end
	end

	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				-- border = 'rounded',
				source = 'always',
				prefix = utf8(0xf082d) .. ' ',
				scope = 'cursor',
			}
			vim.diagnostic.open_float(nil, opts)
		end
	})

	-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
	-- 	vim.lsp.handlers.hover,
	-- 	{ border = "rounded" }
	-- )
	-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	-- 	vim.lsp.handlers.signature_help,
	-- 	{ border = "rounded" }
	-- )
	-- require("lspconfig.ui.windows").default_options = {
	-- 	border = "rounded"
	-- }

	require("core.mappings").lsp_mappings(bufnr)
end

return M
