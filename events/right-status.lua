local wezterm = require("wezterm")
local umath = require("utils.math")
local Cells = require("utils.cells")
local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

-- stylua: ignore
local discharging_icons = {
   nf.md_battery_10,
   nf.md_battery_20,
   nf.md_battery_30,
   nf.md_battery_40,
   nf.md_battery_50,
   nf.md_battery_60,
   nf.md_battery_70,
   nf.md_battery_80,
   nf.md_battery_90,
   nf.md_battery,
}
-- stylua: ignore
local charging_icons = {
   nf.md_battery_charging_10,
   nf.md_battery_charging_20,
   nf.md_battery_charging_30,
   nf.md_battery_charging_40,
   nf.md_battery_charging_50,
   nf.md_battery_charging_60,
   nf.md_battery_charging_70,
   nf.md_battery_charging_80,
   nf.md_battery_charging_90,
   nf.md_battery_charging,
}

-- stylua: ignore
local colors = {
   date      = { fg = "#7aa2f7", bg = "#1a1b26" },
   battery   = { fg = "#9ece6a", bg = "#1a1b26" },
   charging  = { fg = "#7dcfff", bg = "#1a1b26" },
   low       = { fg = "#f7768e", bg = "#1a1b26" },
   separator = { fg = "#a9b1d6", bg = "#1A1B26" },
}

local cells = Cells:new()
   :add_segment("date_icon", nf.fa_calendar .. " ", colors.date, attr(attr.intensity("Bold")))
   :add_segment("date_text", "", colors.date, attr(attr.intensity("Bold")))
   :add_segment("separator", " | ", colors.separator)
   :add_segment("battery_text", "", colors.battery, attr(attr.intensity("Bold")))
   :add_segment("battery_icon", " ", colors.battery)

local function battery_info()
   local charge = ""
   local icon = ""
   local fg = colors.battery.fg

   for _, b in ipairs(wezterm.battery_info()) do
      local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
      charge = string.format("%.0f%%", b.state_of_charge * 100)

      if b.state == "Charging" or b.state == "Full" then
         icon = charging_icons[idx]
         fg = colors.charging.fg
      else
         icon = discharging_icons[idx]
         if b.state_of_charge <= 0.2 then
            fg = colors.low.fg
         end
      end
      break  -- only primary battery
   end

   return charge .. " ", icon .. " ", fg
end

M.setup = function(opts)
   local date_format = (opts or {}).date_format or " %a %H:%M:%S"

   wezterm.on("update-right-status", function(window, _pane)
      local battery_text, battery_icon, battery_fg = battery_info()

      cells
         :update_segment_text("date_text", wezterm.strftime(date_format))
         :update_segment_text("battery_icon", battery_icon)
         :update_segment_text("battery_text", battery_text)
         :update_segment_colors("battery_icon", { fg = battery_fg })
         :update_segment_colors("battery_text", { fg = battery_fg })

      local has_battery = battery_text ~= "" and battery_icon ~= " "
      local render_ids = has_battery
         and { "date_icon", "date_text", "separator", "battery_icon", "battery_text" }
         or  { "date_icon", "date_text" }

      window:set_right_status(wezterm.format(cells:render(render_ids)))
   end)
end

return M
