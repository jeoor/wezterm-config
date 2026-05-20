local wezterm = require("wezterm")
local platform = require("utils.platform")

local font = "JetBrainsMono NF"
local cjk_font = "HarmonyOS Sans SC"
local font_size = platform.is_mac and 14 or (platform.is_win and 12 or 11)

return {
  font = wezterm.font_with_fallback({
    { family = font, weight = "Medium" },
    { family = cjk_font, weight = "Medium" },
  }),
  font_size = font_size,

  --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
  freetype_load_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
  freetype_render_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
