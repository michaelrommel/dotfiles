local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = {}
local winsize = {}

local fontname = "VictorMono NF"
local fontsize = 17

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.launch_menu = {
		{
			label = "cygwin",
			args = { "cmd.exe", "/c", "c:/cygwin64/bin/bash.exe --login -i" },
			domain = "DefaultDomain",
		},
		{
			label = "SSH bookworm",
			domain = { DomainName = "SSH.bookworm" },
		},
	}
	config.ssh_domains = {
		{
			name = "SSH.bookworm",
			remote_address = "192.168.140.18",
			username = "rommel",
			multiplexing = "None",
			default_prog = { "zsh" },
			assume_shell = "Posix",
		},
		{
			name = "SSH.trixie",
			remote_address = "192.168.140.18",
			username = "rommel",
			multiplexing = "None",
			default_prog = { "zsh" },
			assume_shell = "Posix",
		},
	}
	-- config.default_cwd = "C:/cygwin64/bin"
	-- config.default_prog = { "cmd.exe", "/c", "c:/cygwin64/bin/bash.exe --login -i" }
	-- config.default_domain = 'WSL:neoplain'
	-- config.default_domain = 'SSH:WSL'
	config.default_domain = "WSL:bookworm"
	config.ssh_backend = "LibSsh"
	fontname = "VictorMono NF"
	fontsize = 13
	-- this conflicts with the csi u mode that we need for
	-- tmux and extended key reporting
	config.allow_win32_input_mode = false
	config.initial_rows = 40
	config.initial_cols = 120
	winsize.height = 1000
	winsize.width = 1200
	config.window_padding = {
		left = 0,
		right = 22,
		top = 3,
		bottom = 0,
	}
else
	config.term = "wezterm"
	config.initial_rows = 45
	config.initial_cols = 150
	winsize.height = 1100
	winsize.width = 1400
	config.window_padding = {
		left = 0,
		right = 22,
		top = 0,
		bottom = 0,
	}
end

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = true
config.font = wezterm.font(fontname)
config.font_rules = {
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font({
			family = fontname,
			weight = "Regular",
		}),
	},
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = fontname,
			weight = "Medium",
		}),
	},
	{
		intensity = "Half",
		italic = false,
		font = wezterm.font({
			family = fontname,
			weight = "Light",
		}),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = fontname,
			weight = "Light",
			style = "Italic",
		}),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = fontname,
			weight = "Medium",
			style = "Italic",
		}),
	},
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font({
			family = fontname,
			weight = "ExtraLight",
			style = "Italic",
		}),
	},
}
config.font_size = fontsize
config.line_height = 1.00
-- config.bold_brightens_ansi_colors = "BrightAndBold"
config.bold_brightens_ansi_colors = "No"
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "Linear",
	fade_in_duration_ms = 20,
	fade_out_function = "Linear",
	fade_out_duration_ms = 20,
	-- target = "CursorColor",
}

config.max_fps = 72
config.enable_scroll_bar = true
config.min_scroll_bar_height = "2cell"

-- config.debug_key_events = true
-- we define only the most needed commmands below in the key section
-- this leaves us with more combinations for the editor/debugger
config.disable_default_key_bindings = true
-- we need to enable this to gain access to combinations like
-- CTRL-SHIFT-I and so on. On Windows we need to disable the
-- windows input mode above
config.enable_csi_u_key_encoding = true
-- config.enable_kitty_keyboard = true

config.treat_east_asian_ambiguous_width_as_wide = false
config.unicode_version = 9
-- config.normalize_output_to_unicode_nfc = true
config.allow_square_glyphs_to_overflow_width = "Always"
-- config.allow_square_glyphs_to_overflow_width = "never"
-- this is needed because otherwise box drawing characters can overlap
-- e.g. when displaying a tree which causes brightness variations
config.custom_block_glyphs = true
-- uncomment the following to disable ligatures
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.freetype_load_target = "Light"
config.freetype_render_target = "Light"

config.colors = {
	visual_bell = "#202324",
	scrollbar_thumb = wezterm.color.from_hsla(50, 0, 0.6, 0.4)
}
-- see: https://github.com/dawikur/base16-gruvbox-scheme
-- config.color_scheme = 'Gruvbox dark, hard (base16)'
config.color_scheme = "Gruvbox Dark Hard"

config.color_schemes = {
	["Gruvbox Dark Hard"] = {
		foreground = "#ebdbb2",
		background = "#151819",
		-- cursor_bg = "#d5c4a1",
		cursor_bg = "#d79921",
		cursor_border = "#ebdbb2",
		cursor_fg = "#151819",
		selection_bg = "#504945",
		selection_fg = "#ebdbb2",

		ansi = {
			"#151819",
			"#cc241d",
			"#98971a",
			"#d79921",
			"#458588",
			"#b16286",
			"#689d6a",
			"#a89984",
		},
		brights = {
			"#928374",
			"#fb4934",
			"#b8bb26",
			"#fabd2f",
			"#83a598",
			"#d3869b",
			"#8ec07c",
			"#fbf1c7",
		},
	},
}

config.keys = {
	{ key = "Tab", mods = "CTRL",       action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "-",   mods = "CTRL",       action = act.DecreaseFontSize },
	{ key = "0",   mods = "CTRL",       action = act.ResetFontSize },
	{ key = "=",   mods = "CTRL",       action = act.IncreaseFontSize },
	{ key = "C",   mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
	{ key = "L",   mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
	{ key = "N",   mods = "SHIFT|CTRL", action = act.SpawnWindow },
	{ key = "P",   mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	{ key = "T",   mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "V",   mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
	{ key = "c",   mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
	{ key = "l",   mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
	{ key = "n",   mods = "SHIFT|CTRL", action = act.SpawnWindow },
	{ key = "t",   mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "v",   mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
}

-- Custom title and icon based on:
--   https://github.com/wezterm/wezterm/discussions/4945#discussion-6173546
-- : https://github.com/protiumx/.dotfiles/blob/854d4b159a0a0512dc24cbc840af467ac84085f8/stow/wezterm/.config/wezterm/wezterm.lua#L291-L319
local process_icons = {
	["bash"] = wezterm.nerdfonts.dev_terminal,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["curl"] = wezterm.nerdfonts.md_arrow_down_box,
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["gh"] = wezterm.nerdfonts.dev_github,
	["git"] = wezterm.nerdfonts.md_git,
	["go"] = wezterm.nerdfonts.seti_go,
	["htop"] = wezterm.nerdfonts.cod_graph_line,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["kuberlr"] = wezterm.nerdfonts.linux_docker,
	["lazydocker"] = wezterm.nerdfonts.linux_docker,
	["lazygit"] = wezterm.nerdfonts.oct_git_compare,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["make"] = wezterm.nerdfonts.seti_makefile,
	["node"] = wezterm.nerdfonts.md_hexagon_outline,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["psql"] = wezterm.nerdfonts.custom_sqldeveloper,
	["ruby"] = wezterm.nerdfonts.cod_ruby,
	["sudo"] = wezterm.nerdfonts.md_death_star,
	["usql"] = wezterm.nerdfonts.custom_sqldeveloper,
	["vim"] = wezterm.nerdfonts.custom_vim,
	["tmux"] = wezterm.nerdfonts.cod_terminal_tmux,
	["wget"] = wezterm.nerdfonts.md_arrow_down_box,
	["wslhost.exe"] = wezterm.nerdfonts.custom_windows,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
}

-- Return the Tab's current working directory
local function get_cwd(tab)
	local pane = tab.active_pane
	if not pane then
		return ""
	end
	local cwd = pane.current_working_dir
	if not cwd then
		return ""
	end
	return cwd.file_path or ""
end

-- Remove all path components and return only the last value
local function remove_abs_path(path)
	return path:gsub("(.*[/\\])(.*)", "%2")
end

-- Return the concise name or icon of the running process for display
-- local function get_process(tab)
-- 	if not tab.active_pane or tab.active_pane.foreground_process_name == "" then
-- 		return nil
-- 	end
-- 	return remove_abs_path(tab.active_pane.foreground_process_name)
-- end

local function format_process(process_name)
	if process_name:find("kubectl") then
		process_name = "kubectl"
	end
	local icon = process_icons[process_name]
	if icon then
		icon = icon .. " "
	end
	return icon or string.format("[%s] ", process_name)
end

-- Pretty format the tab title
local function format_title(tab)
	-- local process1 = get_process(tab)
	-- if process1 then
	-- 	process1 = format_process(process1)
	-- else
	-- 	process1 = ""
	-- end

	local apane = tab.active_pane
	local active_title = apane.title
	local process2 = nil
	local count = 0
	if apane.user_vars.WEZTERM_IN_TMUX == "1" then
		if active_title then
			process2, count = string.gsub(active_title, ".*%[(.-)%] .*", "%1")
		end
		if count > 0 then
			process2 = format_process(process2)
			active_title = active_title:gsub(".*%[.-%] (.*)", "%1")
		else
			process2 = ""
		end
		process2 = process_icons["tmux"] .. "  " .. process2
	else
		process2 = apane.user_vars.WEZTERM_PROG
		if process2 then
			process2, count = string.gsub(process2, "([^ ;]+).*", "%1")
			if count > 0 then
				process2 = remove_abs_path(process2)
				process2 = format_process(process2)
			else
				process2 = ""
			end
		else
			process2 = ""
		end
	end

	local description = (not active_title) and "!" or active_title
	return string.format("%s %s", process2, description)
end

-- Returns manually set title (from `tab:set_title()` or `wezterm cli set-tab-title`)
-- or creates a new one
local function get_tab_title(tab)
	local title = tab.tab_title
	if title and #title > 0 then
		return title
	end
	return format_title(tab)
end

-- Convert arbitrary strings to a unique hex color value
-- Based on: https://stackoverflow.com/a/3426956/3219667
local function string_to_color(str)
	-- Convert the string to a unique integer
	local hash = 0
	for i = 1, #str do
		hash = string.byte(str, i) + ((hash << 5) - hash)
	end

	-- Convert the integer to a unique color
	local hue = (hash & 0x1ff) / 512 * 360
	local saturation = ((hash >> 9) & 255) / 255 * 60
	local c = wezterm.color.from_hsla(hue, saturation, 0.18, 1)
	return c
end

-- Determine if a tab has unseen output since last visited
local function has_unseen_output(tab)
	if not tab.is_active then
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				return true
			end
		end
	end
	return false
end

-- On format tab title events, override the default handling to return a custom title
-- Docs: https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local title = get_tab_title(tab)
	local color = string_to_color(get_cwd(tab))

	if tab.is_active then
		return {
			{ Attribute = { Intensity = "Bold" } },
			{ Background = { Color = color } },
			{ Foreground = { Color = "#ebdbb2" } },
			{ Text = title },
		}
	end
	if has_unseen_output(tab) then
		return {
			{ Foreground = { Color = "#fabd2f" } },
			{ Text = title },
		}
	end
	return title
end)

wezterm.on("window-config-reloaded", function(window, pane)
	local main = wezterm.gui.screens().main
	-- approximately identify this gui window, by using the associated mux id
	local id = "win_" .. window:window_id()
	-- maintain a mapping of windows that we have previously seen before in this event handler
	local seen = wezterm.GLOBAL.seen_windows or {}
	-- set a flag if we haven't seen this window before
	local is_new_window = not seen[id]
	-- and update the mapping
	seen[id] = true
	wezterm.GLOBAL.seen_windows = seen

	-- now act upon the flag
	if is_new_window then
		-- wezterm.log_info(string.format("[new window] created screen: %sx%s, window: %s, pane: %s",
		-- main.width, main.height, window, pane))
		local x = (main.width - winsize.width * main.scale) / 2
		local y = (main.height - winsize.height * main.scale) / 2
		window:set_position(x, y)
	end
end)

return config
