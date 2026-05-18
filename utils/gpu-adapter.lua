local wezterm = require("wezterm")
local platform = require("utils.platform")

local BACKENDS = {
  windows = { Dx12 = 3, Vulkan = 2, Gl = 1 },
  linux = { Vulkan = 2, Gl = 1 },
  mac = { Metal = 1 },
}
local DEVICE_TYPES = { DiscreteGpu = 400, IntegratedGpu = 300, Other = 200, Cpu = 100 }

local available = BACKENDS[platform.os] or {}
local gpus = wezterm.gui and wezterm.gui.enumerate_gpus() or {}
local best, scoreboard = 0, {}

for _, adapter in ipairs(gpus) do
  local score = (available[adapter.backend] or 0) + (DEVICE_TYPES[adapter.device_type] or 0)
  if score > best then best = score end
  scoreboard[score] = adapter
end

return { best = best, scoreboard = scoreboard }
