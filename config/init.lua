local wezterm = require("wezterm")

local Config = {}
Config.__index = Config

-- window positioning disabled: auto-maximize handles startup

function Config:init()
  local options = wezterm.config_builder()
  options:set_strict_mode(true)
  return setmetatable({ options = options, assigned = {} }, self)
end

function Config:append(new_opts)
  assert(type(new_opts) == "table", "config fragment must be a table")
  for k, v in pairs(new_opts) do
    assert(not self.assigned[k], "duplicate config option: " .. k)
    self.options[k] = v
    self.assigned[k] = true
  end
  return self
end

return Config
