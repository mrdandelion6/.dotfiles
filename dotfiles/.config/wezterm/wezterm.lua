local wezterm = require 'wezterm'
local config = {}

-- use the config_builder which will help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_decorations = 'INTEGRATED_BUTTONS | RESIZE'
config.enable_tab_bar = true
config.enable_wayland = false

config.colors = {
  cursor_bg = '#ffffff',
  cursor_fg = '#0C0C0C',
  cursor_border = '#ffffff',
  tab_bar = {
    background = '#0d0e12',
    new_tab = {
      bg_color = '#040505',
      fg_color = '#e8e9eb',
    },
  },
}

-- BACKGROUND IMAGE
local use_background_image = 0 -- toggle this
local home = os.getenv 'HOME'
local image_path = home .. '/.dotfiles/images/dark_mountain.png'

if use_background_image == 1 then
  config.window_background_image = image_path
else
  config.window_background_image = ''
end
config.window_background_opacity = 1.0

config.window_background_image_hsb = {
  brightness = 1.0,
  hue = 1.0,
  saturation = 1.0,
}

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

config.font = wezterm.font('3270 Nerd Font', { weight = 400 })
config.font_size = 13.0
config.font_rasterizer = 'FreeType'
config.freetype_render_target = 'HorizontalLcd'
config.initial_cols = 105
config.initial_rows = 34

config.window_frame = {
  active_titlebar_bg = '#ffffff',
}

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Linear'
config.cursor_blink_ease_out = 'Linear'
config.default_cursor_style = 'BlinkingBlock'
config.window_close_confirmation = 'NeverPrompt'

config.launch_menu = {
  {
    label = 'Bash',
    args = { 'bash' },
  },
  {
    label = 'Zsh',
    args = { 'zsh' },
  },
}

config.freetype_load_flags = 'NO_HINTING'
config.max_fps = 144

config.keys = {
  {
    key = 'Enter',
    mods = 'ALT',
    action = wezterm.action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      local going_fullscreen = not window:get_dimensions().is_full_screen
      overrides.enable_tab_bar = not going_fullscreen
      overrides.window_decorations = going_fullscreen and 'NONE' or 'INTEGRATED_BUTTONS | RESIZE'
      window:set_config_overrides(overrides)
      window:toggle_fullscreen()
    end),
  },
}

return config
