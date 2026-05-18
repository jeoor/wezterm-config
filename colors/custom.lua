-- A slightly altered version of catppucchin mocha
local mocha = {
  rosewater = "#a9b1d6",
  flamingo = "#7aa2f7",
  pink = "#363b54",
  mauve = "#7aa2f7",
  red = "#8BAFED",
  maroon = "#6C87C0",
  peach = "#e0af68",
  yellow = "#B4C7F0",
  green = "#8CD8C5",
  teal = "#76C4D9",
  sky = "#7aa2f7",
  sapphire = "#6386D3",
  blue = "#363b54",
  lavender = "#a9b1d6",
  text = "#a9b1d6",
  subtext1 = "#7aa2f7",
  subtext0 = "#6C87C0",
  overlay2 = "#363b54",
  overlay1 = "#4A5673",
  overlay0 = "#565f89",
  surface2 = "#1A1B26",
  surface1 = "#252A3D",
  surface0 = "#363b54",
  base = "#1A1B26",
  mantle = "#16161e",
  crust = "#15161e",
}

local colorscheme = {
  foreground = mocha.text,
  background = mocha.base,
  cursor_bg = mocha.rosewater,
  cursor_border = mocha.rosewater,
  cursor_fg = mocha.crust,
  selection_bg = mocha.surface0,
  selection_fg = mocha.text,
ansi = {
  "#15161e", "#f7768e", "#9ece6a", "#e0af68",
  "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6",
},
brights = {
  "#414868", "#f7768e", "#9ece6a", "#e0af68",
  "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5",
},
  tab_bar = {
    background = mocha.surface2,
    active_tab = {
      bg_color = mocha.subtext1,
      fg_color = mocha.surface2,
    },
    inactive_tab = {
      bg_color = mocha.overlay2,
      fg_color = mocha.surface2,
    },
    inactive_tab_hover = {
      bg_color = mocha.text,
      fg_color = mocha.surface2,
    },
    new_tab = {
      bg_color = mocha.base,
      fg_color = mocha.text,
    },
    new_tab_hover = {
      bg_color = mocha.text,
      fg_color = mocha.base,
      italic = true,
    },
  },
  visual_bell = mocha.surface0,
  indexed = {
    [16] = mocha.peach,
    [17] = mocha.rosewater,
  },
  scrollbar_thumb = "#414868",
  split = mocha.overlay0,
  compose_cursor = mocha.flamingo, -- nightbuild only
}

return colorscheme
