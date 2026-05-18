local wezterm = require("wezterm")
local Cells = require("utils.cells")
local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

-- Semantic icons for active modes
local mode_icons = {
  copy_mode   = utf8.char(0xf0c5),   -- clipboard (copy)
  search_mode = utf8.char(0xf0b0),   -- funnel
  resize_font = utf8.char(0xf031),   -- font
  resize_pane = utf8.char(0xf065),   -- expand
}

-- Mode-specific bar color
local mode_colors = {
  copy_mode   = "#7dcfff",  -- cyan
  search_mode = "#e0af68",  -- orange
  resize_font = "#9ece6a",  -- green
  resize_pane = "#bb9af7",  -- purple
}

local cells = Cells:new()
  :add_segment(1, nf.ple_left_half_circle_thick, { bg = "rgba(0,0,0,0.4)", fg = "#7aa2f7" }, attr(attr.intensity("Bold")))
  :add_segment(2, " ", { bg = "#7aa2f7", fg = "#1A1B26" }, attr(attr.intensity("Bold")))
  :add_segment(3, " ", { bg = "#7aa2f7", fg = "#1A1B26" }, attr(attr.intensity("Bold")))
  :add_segment(4, nf.ple_right_half_circle_thick, { bg = "rgba(0,0,0,0.4)", fg = "#7aa2f7" }, attr(attr.intensity("Bold")))

M.setup = function()
  wezterm.on("update-status", function(window, _pane)
    local name = window:active_key_table()
    local res = {}
    if name then
      local icon = mode_icons[name] or nf.md_table_key
      local bar_fg = mode_colors[name] or "#7aa2f7"
      cells
        :update_segment_text(2, icon)
        :update_segment_text(3, " " .. string.upper(name))
        :update_segment_colors(1, { fg = bar_fg })
        :update_segment_colors(2, { bg = bar_fg })
        :update_segment_colors(3, { bg = bar_fg })
        :update_segment_colors(4, { fg = bar_fg })
      res = cells:render_all()
    elseif window:leader_is_active() then
      local leader_fg = "#e0af68"
      cells
        :update_segment_text(2, nf.md_key)
        :update_segment_text(3, " LEADER")
        :update_segment_colors(1, { fg = leader_fg })
        :update_segment_colors(2, { bg = leader_fg })
        :update_segment_colors(3, { bg = leader_fg })
        :update_segment_colors(4, { fg = leader_fg })
      res = cells:render_all()
    end
    window:set_left_status(wezterm.format(res))
  end)
end

return M
