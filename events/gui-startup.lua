local wezterm = require("wezterm")
local mux = wezterm.mux
local screen = require("utils.screen")

local M = {}

M.setup = function()
  wezterm.on("gui-startup", function(cmd)
    -- 优先读取上次驻留的屏幕，找不到则回退到当前活跃屏幕
    local scr = screen.find_screen(screen.load_screen_name())
      or wezterm.gui.screens().active

    local ratio = 0.65
    local width, height = scr.width * ratio, scr.height * ratio

    local spawn_args = cmd or {}
    spawn_args.position = {
      x = (scr.width - width) / 2,
      y = (scr.height - height) / 2,
      origin = { Named = scr.name },
    }

    local _, _, window = mux.spawn_window(spawn_args)

    if window then
      local gui = window:gui_window()
      if gui then
        gui:set_inner_size(width, height)
        local s = screen.detect_screen(gui)
        if s then screen.save_screen_name(s.name) end
      end
    end
  end)

  -- 记录当前屏幕的辅助函数
  local function track_screen(win)
    local s = screen.detect_screen(win)
    if s then screen.save_screen_name(s.name) end
  end

  -- 窗口大小变化时更新（全屏切换也会触发）
  wezterm.on("window-resized", track_screen)

  -- 窗口焦点变化时更新（拖到另一块屏幕后点击一下即生效）
  wezterm.on("window-focus-changed", track_screen)
end

return M
