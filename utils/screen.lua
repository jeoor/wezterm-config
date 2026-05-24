local wezterm = require("wezterm")

local M = {}

local state_file = wezterm.config_dir .. "/.screen_state"
local last_saved_name = nil

--- 读取上次驻留的屏幕名称
function M.load_screen_name()
  local f = io.open(state_file, "r")
  if not f then return nil end
  local name = f:read("*l")
  f:close()
  local loaded = (name and #name > 0) and name or nil
  last_saved_name = loaded
  return loaded
end

--- 保存屏幕名称
function M.save_screen_name(name)
  if not name then return end
  if name == last_saved_name then return end
  local f = io.open(state_file, "w")
  if f then
    f:write(name)
    f:close()
    last_saved_name = name
  end
end

--- 根据名称查找屏幕对象
function M.find_screen(name)
  if not name then return nil end
  for _, s in ipairs(wezterm.gui.screens()) do
    if s.name == name then return s end
  end
  return nil
end

--- 通过窗口中心点判断当前所在屏幕
function M.detect_screen(win)
  local dims = win:get_dimensions()
  local cx = dims.pixel_width / 2 + dims.pixel_left
  local cy = dims.pixel_height / 2 + dims.pixel_top
  for _, s in ipairs(wezterm.gui.screens()) do
    if cx >= s.x and cx < s.x + s.width and cy >= s.y and cy < s.y + s.height then
      return s
    end
  end
  return nil
end

return M
