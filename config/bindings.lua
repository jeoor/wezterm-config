local wezterm = require("wezterm")
local platform = require("utils.platform")
local act = wezterm.action

-- =====================================================================
-- Modifier keys
-- =====================================================================
local mod = {}
if platform.is_mac then
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "SUPER|CTRL"
else
  mod.SUPER = "CTRL"
  mod.SUPER_REV = "SHIFT|CTRL"
end
-- LEADER = SHIFT|CTRL + Space

-- =====================================================================
-- Key bindings
-- =====================================================================
local keys = {}

-- ==================== General / Misc (all Ctrl+ prefix) ====================
do
  local t = {
    { key = "F1", mods = "CTRL", action = "ActivateCopyMode" },
    { key = "F2", mods = "CTRL", action = act.ActivateCommandPalette },
    { key = "F3", mods = "CTRL", action = act.ShowLauncher },
    { key = "F4", mods = "CTRL", action = act.ShowTabNavigator },
    { key = "F5", mods = "CTRL", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    { key = "F11", mods = "CTRL", action = act.ToggleFullScreen },
    { key = "F12", mods = "CTRL", action = act.ShowDebugOverlay },
    { key = "f", mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = "" }) },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== QuickSelect URL ====================
-- master uses SUPER_REV+u, but USER uses Shift+Ctrl+u for WSL:Ubuntu
-- Adapted: Shift+Ctrl+o (o=open)
do
  local url_patterns = {
    "\\((https?://\\S+)\\)", "\\[(https?://\\S+)\\]", "\\{(https?://\\S+)\\}",
    "<(https?://\\S+)>", "\\bhttps?://\\S+[)/a-zA-Z0-9-]+",
  }
  table.insert(keys, {
    key = "o", mods = mod.SUPER_REV,
    action = wezterm.action.QuickSelectArgs({
      label = "open url",
      patterns = url_patterns,
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        if url and #url > 0 then
          wezterm.log_info("opening: " .. url)
          wezterm.open_with(url)
        end
      end),
    }),
  })
end

-- ==================== Copy / Paste / Input ====================
do
  local t = {
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    { key = "Enter", mods = "SHIFT", action = act.SendString("\n") },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== Cursor movement (master) ====================
do
  local t = {
    { key = "LeftArrow", mods = mod.SUPER, action = act.SendString("\u{1b}OH") },
    { key = "RightArrow", mods = mod.SUPER, action = act.SendString("\u{1b}OF") },
    { key = "Backspace", mods = mod.SUPER, action = act.SendString("\u{15}") },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== Tabs ====================
do
  local t = {
    { key = "t", mods = mod.SUPER, action = act.SpawnTab("DefaultDomain") },
    { key = "t", mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = "WSL:Arch" }) },
    { key = "u", mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = "WSL:Ubuntu" }) },
    { key = "w", mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },
    { key = "[", mods = mod.SUPER, action = act.ActivateTabRelative(-1) },
    { key = "]", mods = mod.SUPER, action = act.ActivateTabRelative(1) },
    { key = "[", mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
    { key = "]", mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },
    -- rename tab (USER: Shift+Ctrl+R, master: Ctrl+0)
    { key = "R", mods = mod.SUPER_REV, action = act.PromptInputLine {
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then window:active_tab():set_title(line) end
      end),
    }},
    { key = "0", mods = mod.SUPER, action = act.PromptInputLine {
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then window:active_tab():set_title(line) end
      end),
    }},
    -- undo rename (master: SUPER_REV+0)
    { key = "0", mods = mod.SUPER_REV, action = act.EmitEvent("tabs.reset-tab-title") },
    -- toggle tab-bar (master: SUPER+9)
    { key = "9", mods = mod.SUPER, action = act.EmitEvent("tabs.toggle-tab-bar") },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- Ctrl+1..8 → activate tab (USER)
for i = 1, 8 do
  table.insert(keys, { key = tostring(i), mods = mod.SUPER, action = act.ActivateTab(i - 1) })
end

-- ==================== Window ====================
do
  table.insert(keys, { key = "n", mods = mod.SUPER, action = act.SpawnWindow })
end

-- ==================== Panes: Split / Zoom / Close ====================
do
  local t = {
    { key = [[/]], mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = [[\]], mods = "CTRL|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = [[-]], mods = "CTRL|ALT", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "z", mods = "CTRL|ALT", action = act.TogglePaneZoomState },
    { key = "w", mods = mod.SUPER, action = act.CloseCurrentPane({ confirm = false }) },
    -- master: SUPER+Enter = TogglePaneZoomState (alternative)
    { key = "Enter", mods = mod.SUPER, action = act.TogglePaneZoomState },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== Panes: Navigation ====================
-- USER: Shift+Arrows
-- master also adds SUPER_REV+h/j/k/l (Vim-style) + SUPER_REV+p (PaneSelect swap)
do
  local arrows = { UpArrow = "Up", DownArrow = "Down", LeftArrow = "Left", RightArrow = "Right" }
  for k, v in pairs(arrows) do
    table.insert(keys, { key = k, mods = "SHIFT", action = act.ActivatePaneDirection(v) })
  end
  -- hjkl alternative (master: SUPER_REV+k/j/h/l)
  local hjkl = { k = "Up", j = "Down", h = "Left", l = "Right" }
  for k, v in pairs(hjkl) do
    table.insert(keys, { key = k, mods = mod.SUPER_REV, action = act.ActivatePaneDirection(v) })
  end
  -- PaneSelect swap (master: SUPER_REV+p)
  table.insert(keys, { key = "p", mods = mod.SUPER_REV, action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }) })
end

-- ==================== Panes: Resize ====================
do
  local dirs = { UpArrow = "Up", DownArrow = "Down", LeftArrow = "Left", RightArrow = "Right" }
  for k, v in pairs(dirs) do
    table.insert(keys, { key = k, mods = "CTRL|ALT", action = act.AdjustPaneSize({ v, 1 }) })
  end
end

-- ==================== Panes: Scroll (master) ====================
-- master: SUPER+u/d (scroll 5 lines)
-- USER Ctrl+u conflicts with shell clear-line, Ctrl+d with EOF
-- Adapted: Alt+u / Alt+d (FREE, no shell conflict)
do
  local t = {
    { key = "u", mods = "ALT", action = act.ScrollByLine(-5) },
    { key = "d", mods = "ALT", action = act.ScrollByLine(5) },
    { key = "PageUp", mods = "NONE", action = act.ScrollByPage(-0.75) },
    { key = "PageDown", mods = "NONE", action = act.ScrollByPage(0.75) },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== Font size ====================
do
  local t = {
    { key = "UpArrow", mods = mod.SUPER, action = act.IncreaseFontSize },
    { key = "DownArrow", mods = mod.SUPER, action = act.DecreaseFontSize },
    { key = "r", mods = mod.SUPER, action = act.ResetFontSize },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== Background images ====================
do
  local t = {
    { key = [[/]], mods = mod.SUPER, action = act.EmitEvent("backdrops.random") },
    { key = [[,]], mods = mod.SUPER, action = act.EmitEvent("backdrops.cycle-back") },
    { key = [[.]], mods = mod.SUPER, action = act.EmitEvent("backdrops.cycle-forward") },
    { key = "b", mods = mod.SUPER, action = act.EmitEvent("backdrops.toggle-focus") },
    { key = [[/]], mods = mod.SUPER_REV, action = act.EmitEvent("backdrops.fuzzy-select") },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- ==================== Leader key-tables (master) ====================
local key_tables = {
  resize_font = {
    { key = "k", action = act.IncreaseFontSize },
    { key = "j", action = act.DecreaseFontSize },
    { key = "r", action = act.ResetFontSize },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
  },
  resize_pane = {
    { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
  },
}

do
  local t = {
    { key = "f", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_font", one_shot = false, timeout_milliseconds = 1000 }) },
    { key = "p", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 1000 }) },
  }
  for _, v in ipairs(t) do table.insert(keys, v) end
end

-- =====================================================================
-- Mouse bindings
-- =====================================================================
local mouse_bindings = {
  { event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
  { event = { Down = { streak = 1, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Cell") },
  { event = { Up = { streak = 1, button = "Left" } }, mods = "NONE", action = act.ExtendSelectionToMouseCursor("Cell") },
  { event = { Drag = { streak = 1, button = "Left" } }, mods = "NONE", action = act.ExtendSelectionToMouseCursor("Cell") },
  { event = { Down = { streak = 2, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Word") },
  { event = { Up = { streak = 2, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Word") },
  { event = { Down = { streak = 3, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Line") },
  { event = { Up = { streak = 3, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Line") },
  { event = { Up = { streak = 1, button = "Right" } }, mods = "NONE", action = act.PasteFrom("Clipboard") },
  { event = { Down = { streak = 1, button = { WheelUp = 1 } } }, mods = "NONE", action = act.ScrollByCurrentEventWheelDelta },
  { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = "NONE", action = act.ScrollByCurrentEventWheelDelta },
}

-- =====================================================================
-- Export
-- =====================================================================
return {
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  leader = { key = "Space", mods = mod.SUPER_REV },
  keys = keys,
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
