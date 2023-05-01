local M = {}
local fn = vim.fn

M.find_files_from_project_git_root = function()
	local function is_git_repo()
		fn.system("git rev-parse --is-inside-work-tree")
		return vim.v.shell_error == 0
	end

	local function get_git_root()
		local dot_git_path = fn.finddir(".git", ".;")
		return fn.fnamemodify(dot_git_path, ":h")
	end

	local opts = {}
	if is_git_repo() then
		opts = {
			cwd = get_git_root(),
			hidden = true,
			file_ignore_patterns = { "^.git" },
		}
	end
	require("telescope.builtin").find_files(opts)
end
return M
