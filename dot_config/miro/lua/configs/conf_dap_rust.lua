local M = {}

local dap = require("dap")
local mr = require("mason-registry")
local utils = require("core.utils")

-- this gets used in nvim-dap and rust-tools
M.get_codelldb_adapter = function()
	local command = nil
	local args = nil
	local code = nil
	local lib = vim.fn.expand "$MASON/packages/codelldb/extension/lldb/lib"

	if utils.is_mac then
		-- print(string.format("mac: %s", code))
		command = "codelldb"
		args = {
			"--liblldb", lib .. "/liblldb.dylib",
			"--settings", '{"showDisassembly": "never", "sourceLanguages": ["rust"]}'
		}
	else
		-- print(string.format("linux: %s", code))
		command = "codelldb"
		args = {
			"--liblldb", lib .. "/liblldb.so",
			"--settings", '{"showDisassembly": "never", "sourceLanguages": ["rust"]}'
		}
	end
	-- local host = "127.0.0.1"
	-- local port = 13333
	return {
		type = "server",
		port = "${port}",
		executable = {
			command = command,
			args = vim.list_extend({ "--port", "${port}" }, args)
		}
	}
end

M.setup = function()
	dap.adapters.codelldb = M.get_codelldb_adapter()

	local function get_arguments()
		local co = coroutine.running()
		if co then
			return coroutine.create(function()
				local args = {}
				vim.ui.input({ prompt = 'Enter command-line arguments: ' }, function(input)
					args = vim.split(input, " ")
				end)
				coroutine.resume(co, args)
			end)
		else
			local args = {}
			vim.ui.input({ prompt = 'Enter command-line arguments: ' }, function(input)
				args = vim.split(input, " ")
			end)
			return args
		end
	end

	dap.configurations.rust = {
		{
			type = "codelldb",
			request = "launch",
			name = "Debug",
			program = function()
				return vim.fn.input("exe: ", vim.fn.getcwd() .. "/target/debug/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			showDisassembly = "never",
			args = get_arguments,
		},
	}
end

return M
