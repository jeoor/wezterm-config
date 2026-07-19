local wezterm = require("wezterm")
local launch_menu = require("config.launch").launch_menu
local domains = require("config.domains")
local Cells = require("utils.cells")
local OptsValidator = require("utils.opts-validator")
local nf = wezterm.nerdfonts
local act = wezterm.action
local attr = Cells.attr

local M = {}

local cells = Cells:new()
  :add_segment("icon", " " .. nf.oct_terminal .. " ", { fg = "#7aa2f7" })
  :add_segment("wsl", " " .. nf.cod_terminal_linux .. " ", { fg = "#7aa2f7" })
  :add_segment("label", "", { fg = "#a9b1d6" }, attr(attr.intensity("Bold")))

local launch_menu_schema = OptsValidator:new({
  { name = "label", type = "string", required = true },
  { name = "args", type = "table", table_of = "string", required = true },
})

local choices, data = {}, {}
for _, v in ipairs(launch_menu) do
  local valid, err = launch_menu_schema:validate(v)
  if err then
    wezterm.log_warn("launch_menu: skipping invalid entry: " .. err)
  else
    cells:update_segment_text("label", valid.label)
    table.insert(choices, { id = tostring(#choices + 1), label = wezterm.format(cells:render({ "icon", "label" })) })
    table.insert(data, { args = valid.args, domain = "DefaultDomain" })
  end
end
for _, v in ipairs(domains.wsl_domains) do
  cells:update_segment_text("label", v.name)
  table.insert(choices, { id = tostring(#choices + 1), label = wezterm.format(cells:render({ "wsl", "label" })) })
  table.insert(data, { domain = { DomainName = v.name } })
end

M.setup = function()
  wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
    if button == "Left" and default_action then window:perform_action(default_action, pane) end
    if button == "Right" then
      window:perform_action(act.InputSelector({
        title = "InputSelector: Launch Menu", choices = choices, fuzzy = true,
        fuzzy_description = nf.md_rocket .. " Select: ",
        action = wezterm.action_callback(function(_w, _p, id)
          if id then window:perform_action(act.SpawnCommandInNewTab(data[tonumber(id)]), pane) end
        end),
      }), pane)
    end
    return false
  end)
end

return M
