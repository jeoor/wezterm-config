local wezterm = require("wezterm")

---@class Config
---@field options table
local Config = {}

--set the position of new window to a fixed position
wezterm.on("window-config-reloaded", function(window, pane)
	local id = tostring(window:window_id())
	local seen = wezterm.GLOBAL.seen_windows or {}
	local is_new_window = not seen[id]
	seen[id] = true
	wezterm.GLOBAL.seen_windows = seen
	if is_new_window then
		window:set_position(500, 300)
	end
end)

---Initialize Config
---@return Config
function Config:init()
  local o = {}
  self = setmetatable(o, { __index = Config })
  self.options = {}
  return o
end

---Append to `Config.options`
---@param new_options table new options to append
---@return Config
function Config:append(new_options)
  for k, v in pairs(new_options) do
    if self.options[k] ~= nil then
      wezterm.log_warn(
        'Duplicate config option detected: ',
        { old = self.options[k], new = new_options[k] }
      )
      goto continue
    end
    self.options[k] = v
    ::continue::
  end
  return self
end

return Config
