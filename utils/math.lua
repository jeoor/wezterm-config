local M = {}

function M.round(num) return math.floor(num + 0.5) end

function M.clamp(val, low, high)
  if val < low then return low elseif val > high then return high end
  return val
end

return M
