-- yanks stuff into tmux and system clipboards
return {
	"ibhagwan/smartyank.nvim",
	lazy = true,
	event = "BufEnter",
	opts = {
		highlight = {
			enabled = true, -- highlight yanked text
			higroup = "IncSearch", -- highlight group of yanked text
			timeout = 2000, -- timeout for clearing the highlight
		},
		clipboard = {
			enabled = true
		},
		osc52 = {
			enabled = true,
			-- escseq = 'tmux',     -- use tmux escape sequence, only enable if
			-- you're using tmux and have issues (see #4)
			ssh_only = false, -- false to OSC52 yank also in local sessions
			silent = false, -- true to disable the "n chars copied" echo
			echo_hl = "Directory", -- highlight group of the OSC52 echo message
		},
	}
}
