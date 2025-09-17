local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("MonoLisa Nerd Font")
config.color_scheme = "Gruvbox Material (Gogh)"
config.font_size = 18
config.window_background_opacity = 0.8
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { top = "1cell" }
config.macos_window_background_blur = 20
config.hide_tab_bar_if_only_one_tab = true

return config
