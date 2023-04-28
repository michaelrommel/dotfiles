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

	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
	vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
	vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
	vim.keymap.set('n', '<Leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, opts)
	vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
	vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)
end

return M
