local wezterm = require("wezterm")
local colors = require("colors.custom")

return {
  term = "xterm-256color",
  animation_fps = 60,
  max_fps = 60,
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",
  webgpu_preferred_adapter = require("utils.gpu-adapter").scoreboard[require("utils.gpu-adapter").best], -- auto-detect best GPU
  underline_thickness = "1.5pt",

  -- color scheme
  colors = colors,
  -- color_scheme = "tokyonight_moon",
  -- color_scheme = "Gruvbox dark, medium (base16)",
	-- color_scheme = 'Night Owl (Gogh)',
	color_scheme = "tokyonight_night",

  -- background
  window_background_opacity = 0.95,
  win32_system_backdrop = "Acrylic",
  window_background_gradient = {
    colors = { "#1a1b26", "#363b54" },
    orientation = { Linear = { angle = -45.0 } }
  },
  -- background managed by utils/backdrops module

  -- scrollbar
  enable_scroll_bar = true,
  min_scroll_bar_height = "3cell",
  -- tab bar
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = true,
  tab_max_width = 25,
  show_tab_index_in_tab_bar = true,
  switch_to_last_active_tab_when_closing_tab = true,

  -- cursor
  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  cursor_blink_rate = 700,

  -- window
  adjust_window_size_when_changing_font_size = false,
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  integrated_title_button_style = "Windows",
  integrated_title_button_color = "auto",
  integrated_title_button_alignment = "Right",
  initial_cols = 115,
  initial_rows = 30,
  window_padding = {
    left = 5,
    right = 10,
    top = 12,
    bottom = 7,
  },
  window_close_confirmation = "NeverPrompt",
  window_frame = {
    active_titlebar_bg = "#1A1B26",
    inactive_titlebar_bg = "#1A1B26",
  },
  inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 1.0,
  },
  -- command palette
  command_palette_fg_color = "#a9b1d6",
  command_palette_bg_color = "#1A1B26",
  command_palette_font_size = 12,
  command_palette_rows = 25,

  -- visual bell: flash cursor instead of beeping
  visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 250,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 250,
    target = "CursorColor",
  },
}
