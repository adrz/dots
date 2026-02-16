-- Pull in the wezterm API
local wezterm = require("wezterm")
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").main

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action
config.send_composed_key_when_left_alt_is_pressed = true
-- config.send_composed_key_when_right_alt_is_pressed = true
config.use_dead_keys = false

-- keybinding
config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = "n",
		mods = "ALT",
		action = wezterm.action.SendString("~"),
	},
	{
		key = "(",
		mods = "ALT",
		action = wezterm.action.SendString("{"),
	},
	{
		key = ")",
		mods = "ALT",
		action = wezterm.action.SendString("}"),
	},
	{
		key = "(",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("["),
	},
	{
		key = ")",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("]"),
	},
	{
		key = "L",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("|"),
	},
	{
		key = ":",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("\\"),
	},
	{
		key = "h",
		mods = "ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "UpArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "DownArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "p",
		mods = "ALT",
		action = wezterm.action.ActivateCommandPalette,
	},
	{
		key = "LeftArrow",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Left", 1 }),
	},
	-- Augmente la largeur (droite)
	{
		key = "RightArrow",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Right", 1 }),
	},
	-- Diminue la hauteur (haut)
	{
		key = "UpArrow",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Up", 1 }),
	},
	-- Augmente la hauteur (bas)
	{
		key = "DownArrow",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Down", 1 }),
	},
}

config.ssh_domains = {
	{
		name = "da-server", -- Un nom simple
		remote_address = "da-server",
	},
}

config.mouse_bindings = {
	{
		event = { Up = { streak = 0, button = "Middle" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},
}

-- This is where you actually apply your config choices

config.color_scheme = "Batman"
--config.color_scheme = "Gogh (Gogh)"
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16

-- config.enable_tab_bar = true

-- Define an event to toggle the tab bar visibility
config.enable_tab_bar = true
config.window_decorations = "RESIZE"

config.window_background_opacity = 0.8
config.macos_window_background_blur = 10

-- my coolnight colorscheme:
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#87A4BA", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

-- and finally, return the configuration to wezterm
return config
