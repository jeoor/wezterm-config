local wezterm = require("wezterm")
local Cells = require("utils.cells")
local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

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
      cells:update_text(2, nf.md_table_key):update_text(3, " " .. string.upper(name))
      res = cells:render({ 1, 2, 3, 4 })
    end
    if window:leader_is_active() then
      cells:update_text(2, nf.md_key):update_text(3, " LEADER")
      res = cells:render({ 1, 2, 3, 4 })
    end
    window:set_left_status(wezterm.format(res))
  end)
end

return M
