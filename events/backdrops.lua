local wezterm = require("wezterm")
local backdrops = require("utils.backdrops")
local nf = wezterm.nerdfonts

local M = {}

M.setup = function()
  wezterm.on("backdrops.random", function(w) backdrops:random(w) end)
  wezterm.on("backdrops.cycle-forward", function(w) backdrops:cycle_forward(w) end)
  wezterm.on("backdrops.cycle-back", function(w) backdrops:cycle_back(w) end)
  wezterm.on("backdrops.toggle-focus", function(w) backdrops:toggle_focus(w) end)
  wezterm.on("backdrops.fuzzy-select", function(window, pane)
    local choices = backdrops:choices()
    if #choices == 0 then return end
    window:perform_action(
      wezterm.action.InputSelector({
        title = "InputSelector: Select Background",
        choices = choices, fuzzy = true,
        fuzzy_description = nf.md_rocket .. " Select: ",
        action = wezterm.action_callback(function(_w, _p, idx) if idx then backdrops:set_img(window, tonumber(idx)) end end),
      }), pane)
  end)
end

return M
