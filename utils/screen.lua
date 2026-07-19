local wezterm = require("wezterm")

local M = {}

local state_file = wezterm.config_dir .. "/.screen_state"
local last_saved_name = nil
local retry_after = 0
local SAVE_RETRY_SECONDS = 60

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
  local now = os.time()
  if not name or name == last_saved_name or now < retry_after then return end

  local f, open_error = io.open(state_file, "w")
  if not f then
    wezterm.log_warn("cannot save screen state: " .. tostring(open_error))
    retry_after = now + SAVE_RETRY_SECONDS
    return
  end

  local written, write_error = f:write(name)
  local closed, close_error = f:close()
  if not written or not closed then
    wezterm.log_warn("cannot save screen state: " .. tostring(write_error or close_error))
    retry_after = now + SAVE_RETRY_SECONDS
    return
  end
  last_saved_name = name
  retry_after = 0
end

--- 根据名称查找屏幕对象
function M.find_screen(name)
  if not name then return nil end
  return wezterm.gui.screens().by_name[name]
end

--- 返回当前获得输入焦点的屏幕
function M.active_screen()
  return wezterm.gui.screens().active
end

return M
