local M = {}

local deprecatedFormatters = { "tsserver", "jsonls" }

-- needs to be a global to be used also as formatexpr
function Lspformatter(bufnr)
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

	-- print(string.format("%s -> %s", client.name, client.server_capabilities.documentRangeFormattingProvider))
	if client.supports_method("textDocument/formatting") then
		local deprecated = false
		for _, n in ipairs(deprecatedFormatters) do
			deprecated = deprecated or client.name == n
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
					Lspformatter(bufnr)
				end,
			})
			-- we can use the lsp formatter also for gq commands
			vim.api.nvim_buf_set_option(bufnr, "formatexpr", 'v:lua.Lspformatter()')
		end
	end

	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = 'rounded',
				source = 'always',
				prefix = ' ',
				scope = 'cursor',
			}
			vim.diagnostic.open_float(nil, opts)
		end
	})

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
		vim.lsp.handlers.hover,
		{ border = "rounded" }
	)
	require("core.mappings").lsp_mappings(bufnr)
end

return M
