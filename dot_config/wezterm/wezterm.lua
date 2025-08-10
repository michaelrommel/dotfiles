local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

local fontname = 'VictorMono NF'
local fontsize = 17

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
	config.launch_menu = {
		{
			label = "cygwin",
			args = { "cmd.exe", "/c", "c:/cygwin64/bin/bash.exe --login -i" },
			domain = 'DefaultDomain'
		}
	}
	-- config.default_cwd = "C:/cygwin64/bin"
	-- config.default_prog = { "cmd.exe", "/c", "c:/cygwin64/bin/bash.exe --login -i" }
	-- config.default_domain = 'WSL:neoplain'
	-- config.default_domain = 'SSH:WSL'
	config.default_domain = 'WSL:bookworm'
	config.ssh_backend = "Ssh2"
	fontname = 'VictorMono NF'
	fontsize = 13
	config.initial_rows = 40
	config.initial_cols = 120
	-- this conflicts with the csi u mode that we need for
	-- tmux and extended key reporting
	config.allow_win32_input_mode = false
else
	config.term = "wezterm"
	config.initial_rows = 45
	config.initial_cols = 150
end

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.use_fancy_tab_bar = true
config.font = wezterm.font(fontname)
config.font_rules = {
	{
		intensity = 'Normal',
		italic = false,
		font = wezterm.font {
			family = fontname,
			weight = 'Regular',
		},
	},
	{
		intensity = 'Bold',
		italic = false,
		font = wezterm.font {
			family = fontname,
			weight = 'Medium',
		},
	},
	{
		intensity = 'Half',
		italic = false,
		font = wezterm.font {
			family = fontname,
			weight = 'Light',
		},
	},
	{
		intensity = 'Normal',
		italic = true,
		font = wezterm.font {
			family = fontname,
			weight = 'Light',
			style = 'Italic',
		},
	},
	{
		intensity = 'Bold',
		italic = true,
		font = wezterm.font {
			family = fontname,
			weight = 'Medium',
			style = 'Italic',
		},
	},
	{
		intensity = 'Half',
		italic = true,
		font = wezterm.font {
			family = fontname,
			weight = 'ExtraLight',
			style = 'Italic',
		},
	},
}
config.font_size = fontsize
config.line_height = 1.00
-- config.bold_brightens_ansi_colors = "BrightAndBold"
config.bold_brightens_ansi_colors = "No"
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = 'Linear',
	fade_in_duration_ms = 20,
	fade_out_function = 'Linear',
	fade_out_duration_ms = 20,
	-- target = "CursorColor",
}
config.colors = {
	visual_bell = '#202324',
}

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
-- see: https://github.com/dawikur/base16-gruvbox-scheme
-- config.color_scheme = 'Gruvbox dark, hard (base16)'
config.color_scheme = 'Gruvbox Dark Hard'
config.window_padding = {
	left = 0,
	right = 0,
	top = 3,
	bottom = 0,
}

config.color_schemes = {
	['Gruvbox Dark Hard'] = {
		foreground = "#ebdbb2",
		background = "#1d2021",
		-- cursor_bg = "#d5c4a1",
		cursor_bg = "#d79921",
		cursor_border = "#ebdbb2",
		cursor_fg = "#1d2021",
		selection_bg = "#504945",
		selection_fg = "#ebdbb2",

		ansi = {
			"#1d2021",
			"#cc241d",
			"#98971a",
			"#d79921",
			"#458588",
			"#b16286",
			"#689d6a",
			"#a89984"
		},
		brights = {
			"#928374",
			"#fb4934",
			"#b8bb26",
			"#fabd2f",
			"#83a598",
			"#d3869b",
			"#8ec07c",
			"#fbf1c7"
		}
	},
}

config.keys = {
	{ key = 'Tab', mods = 'CTRL',       action = act.ActivateTabRelative(1) },
	{ key = 'Tab', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },
	{ key = '-',   mods = 'CTRL',       action = act.DecreaseFontSize },
	{ key = '0',   mods = 'CTRL',       action = act.ResetFontSize },
	{ key = '=',   mods = 'CTRL',       action = act.IncreaseFontSize },
	{ key = 'C',   mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
	{ key = 'L',   mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
	{ key = 'N',   mods = 'SHIFT|CTRL', action = act.SpawnWindow },
	{ key = 'P',   mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
	{ key = 'T',   mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
	{ key = 'V',   mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
	{ key = 'c',   mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
	{ key = 'l',   mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
	{ key = 'n',   mods = 'SHIFT|CTRL', action = act.SpawnWindow },
	{ key = 't',   mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
	{ key = 'v',   mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
}

return config
