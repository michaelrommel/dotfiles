-- create code images
local opts = {
	"michaelrommel/nvim-silicon",
	-- dir = '/Users/rommel/Software/michael/nvim-silicon',
	lazy = true,
	-- branch = "wslclipimg",
	main = "nvim-silicon",
	cmd = "Silicon",
	opts = {
		debug = false,
		font = "VictorMono NF=34;Noto Emoji",
		theme = "gruvbox-dark-hard",
		num_separator = "\u{258f} ",
		shadow_color = "#000000",
		window_title = function()
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t")
		end,
		line_offset = function(args)
			return args.line1
		end,
		wslclipboard = "auto",
		wslclipboardcopy = "delete",
		to_clipboard = true,
		output = nil,
		-- output = function()
		-- 	return "./" .. os.date("!%Y-%m-%dT%H-%M-%SZ") .. "_code.png"
		-- end
		language = function()
			local lang = nil
			if vim.bo.filetype == nil or vim.bo.filetype == "" then
				-- if we cannot determine the filetype supply no default argument
				lang = vim.fn.input("Language: ", "")
			else
				-- otherwise have the filetype as preset for most cases
				lang = vim.fn.input("Language: ", vim.bo.filetype)
			end
			if lang and lang ~= "" then
				return lang
			else
				-- dialog was cancelled
				return "md"
			end
		end,
	}
}
-- if an override exists, merge it in here
local exists, override = pcall(require, "custom.overrides.nvim-silicon")
if exists then
	opts.opts = opts.opts or {}
	for k, v in pairs(override) do opts.opts[k] = v end
end
return opts
