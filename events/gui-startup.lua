local wezterm = require("wezterm")
local mux = wezterm.mux
local screen = require("utils.screen")

local M = {}
local WINDOW_RATIO = 0.65

local function copy_table(source)
  local copy = {}
  for key, value in pairs(source or {}) do copy[key] = value end
  return copy
end

M.setup = function()
  wezterm.on("gui-startup", function(cmd)
    -- 优先读取上次驻留的屏幕，找不到则回退到当前活跃屏幕
    local scr = screen.find_screen(screen.load_screen_name())
      or screen.active_screen()
    if not scr then
      wezterm.log_error("cannot determine a screen for the initial window")
      return
    end

    local width = math.max(1, math.floor(scr.width * WINDOW_RATIO + 0.5))
    local height = math.max(1, math.floor(scr.height * WINDOW_RATIO + 0.5))

    local spawn_args = copy_table(cmd)
    spawn_args.position = {
      x = math.floor((scr.width - width) / 2),
      y = math.floor((scr.height - height) / 2),
      origin = { Named = scr.name },
    }

    local _, _, window = mux.spawn_window(spawn_args)

    if window then
      local gui = window:gui_window()
      if gui then
        gui:set_inner_size(width, height)
        screen.save_screen_name(scr.name)
      end
    end
  end)

  -- 记录当前屏幕的辅助函数
  local function track_screen(win)
    -- window-focus-changed 会同时为失焦窗口触发，只记录获得焦点的窗口。
    if not win:is_focused() then return end
    local s = screen.active_screen()
    if s then screen.save_screen_name(s.name) end
  end

  -- 窗口大小变化时更新（全屏切换也会触发）
  wezterm.on("window-resized", track_screen)

  -- 窗口焦点变化时更新（拖到另一块屏幕后点击一下即生效）
  wezterm.on("window-focus-changed", track_screen)

  -- WezTerm 没有窗口移动事件；定期校准可覆盖只移动、不缩放的情况。
  wezterm.on("update-status", track_screen)
end

return M
