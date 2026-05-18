local wezterm = require("wezterm")

local Config = {}

-- window positioning disabled: auto-maximize handles startup

function Config:init() return setmetatable({ options = {} }, { __index = Config }) end

function Config:append(new_opts)
  for k, v in pairs(new_opts) do
    if self.options[k] == nil then self.options[k] = v end
  end
  return self
end

return Config
