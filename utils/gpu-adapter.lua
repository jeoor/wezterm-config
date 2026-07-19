local wezterm = require("wezterm")
local platform = require("utils.platform")

local BACKENDS = {
  windows = { Dx12 = 3, Vulkan = 2, Gl = 1 },
  linux = { Vulkan = 2, Gl = 1 },
  mac = { Metal = 1 },
}
local DEVICE_TYPES = { DiscreteGpu = 400, IntegratedGpu = 300, Other = 200, Cpu = 100 }

local M = {}

function M.pick_best()
  if not wezterm.gui then return nil end

  local ok, adapters = pcall(wezterm.gui.enumerate_gpus)
  if not ok then
    wezterm.log_warn("cannot enumerate WebGPU adapters: " .. tostring(adapters))
    return nil
  end

  local backends = BACKENDS[platform.os] or {}
  local best_adapter, best_score
  for _, adapter in ipairs(adapters) do
    local backend_score = backends[adapter.backend]
    if backend_score then
      local score = backend_score + (DEVICE_TYPES[adapter.device_type] or 0)
      if not best_score or score > best_score then
        best_adapter, best_score = adapter, score
      end
    end
  end
  return best_adapter
end

return M
