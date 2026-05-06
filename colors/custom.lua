-- A slightly altered version of catppucchin mocha
local mocha = {
  rosewater = "#A9B2D4",
  flamingo = "#7BA5F3",
  pink = "#394260",
  mauve = "#7BA5F3",
  red = "#8BAFED",
  maroon = "#6C87C0",
  peach = "#9AB8FF",
  yellow = "#B4C7F0",
  green = "#8CD8C5",
  teal = "#76C4D9",
  sky = "#7BA5F3",
  sapphire = "#6386D3",
  blue = "#394260",
  lavender = "#A9B2D4",
  text = "#A9B2D4",
  subtext1 = "#7BA5F3",
  subtext0 = "#6C87C0",
  overlay2 = "#394260",
  overlay1 = "#4A5673",
  overlay0 = "#5B6B8D",
  surface2 = "#1A1B26",
  surface1 = "#252A3D",
  surface0 = "#2D344A",
  base = "#1A1B26",
  mantle = "#141720",
  crust = "#0E1017",
}

local colorscheme = {
  foreground = mocha.text,
  background = mocha.base,
  cursor_bg = mocha.rosewater,
  cursor_border = mocha.rosewater,
  cursor_fg = mocha.crust,
  selection_bg = mocha.surface2,
  selection_fg = mocha.text,
ansi = {
  "#2D344A",
  "#FF6B7E",
  "#76C4D9",
  "#B4C7F0",
  "#7BA5F3",
  "#6386D3",
  "#89DCEB",
  "#A9B2D4",
},
brights = {
  "#4A5673",
  "#FF8B98",
  "#8CD8C5",
  "#D4E2FF",
  "#9AB8FF",
  "#8BAFED",
  "#A3EDF7",
  "#E0E7FF",
},
  tab_bar = {
    background = "#000000",
    active_tab = {
      bg_color = mocha.surface2,
      fg_color = mocha.text,
    },
    inactive_tab = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
    inactive_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.text,
    },
    new_tab = {
      bg_color = mocha.base,
      fg_color = mocha.text,
    },
    new_tab_hover = {
      bg_color = mocha.mantle,
      fg_color = mocha.text,
      italic = true,
    },
  },
  visual_bell = mocha.surface0,
  indexed = {
    [16] = mocha.peach,
    [17] = mocha.rosewater,
  },
  scrollbar_thumb = mocha.surface2,
  split = mocha.overlay0,
  compose_cursor = mocha.flamingo, -- nightbuild only
}

return colorscheme
