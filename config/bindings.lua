local wezterm = require("wezterm")
local platform = require("utils.platform")()
local act = wezterm.action

local mod = {}

if platform.is_mac then
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "SUPER|CTRL"
elseif platform.is_win or platform.is_linux then
  mod.SUPER = "CTRL" -- to not conflict with Windows key shortcuts
  mod.SUPER_REV = "SHIFT|CTRL"
end

local keys = {
  -- Shift+Enter 发送换行
  { key = "Enter", mods = "SHIFT", action = act.SendString("\n") },

  -- misc/useful --
  { key = "F1", mods = "CTRL", action = "ActivateCopyMode" },
  { key = "F2", mods = "NONE", action = act.ActivateCommandPalette },
  { key = "F3", mods = "NONE", action = act.ShowLauncher },
  { key = "F4", mods = "NONE", action = act.ShowTabNavigator },
  { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
  { key = "F12", mods = "NONE", action = act.ShowDebugOverlay },
  { key = "f", mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = "" }) },

  -- copy/paste --
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- tabs --
  -- tabs: spawn+close
  { key = "t", mods = mod.SUPER, action = act.SpawnTab("DefaultDomain") },
  { key = "c", mods = "CTRL|ALT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "t", mods = mod.SUPER_REV, action = act.SpawnTab ({ DomainName = "WSL:Arch" }) },
  { key = "u", mods = mod.SUPER_REV, action = act.SpawnTab ({ DomainName = "WSL:Ubuntu" }) },
  { key = "w", mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

  -- tabs: navigation
  { key = "[", mods = mod.SUPER, action = act.ActivateTabRelative(-1) },
  { key = "]", mods = mod.SUPER, action = act.ActivateTabRelative(1) },
  { key = "[", mods = "CTRL|ALT", action = act.MoveTabRelative(-1) },
  { key = "]", mods = "CTRL|ALT", action = act.MoveTabRelative(1) },

  -- window --
  -- spawn windows
  { key = "n", mods = mod.SUPER, action = act.SpawnWindow },

  -- panes --
  -- panes: split panes
  {
    key = [[/]],
    mods = "CTRL|ALT",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = [[\]],
    mods = "CTRL|ALT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = [[-]],
    mods = "CTRL|ALT",
    action = act.CloseCurrentPane({ confirm = true }),
  },

  -- panes: zoom+close pane
  { key = "z", mods = "CTRL|ALT", action = act.TogglePaneZoomState },
  { key = "w", mods = mod.SUPER, action = act.CloseCurrentPane({ confirm = false }) },

  -- panes: navigation
  { key = "UpArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "LeftArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "SHIFT", action = act.ActivatePaneDirection("Right") },

  -- panes: resize
  { key = "UpArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "DownArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "LeftArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "RightArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Right", 1 }) },

  -- fonts --
  -- fonts: resize
  { key = "UpArrow", mods = mod.SUPER, action = act.IncreaseFontSize },
  { key = "DownArrow", mods = mod.SUPER, action = act.DecreaseFontSize },
  { key = "r", mods = "CTRL", action = act.ResetFontSize },
  -- rename tab bar
  {
    key = "R",
    mods = mod.SUPER_REV,
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

--CTRL + number to activate that tab
for i = 1, 8 do
    table.insert(keys, {
        key = tostring(i),
        mods = mod.SUPER,
        action = act.ActivateTab(i -1),
    })
end

local mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  -- Move mouse will only select text and not copy text to clipboard
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Cell"),
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.ExtendSelectionToMouseCursor("Cell"),
  },
  {
    event = { Drag = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.ExtendSelectionToMouseCursor("Cell"),
  },
  -- Triple Left click will paste from clipboard
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
  -- Triple Left click will select a line
  {
    event = { Down = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Line"),
  },
  {
    event = { Up = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Line"),
  },
  -- Double Left click will select a word
  {
    event = { Down = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Word"),
  },
  {
    event = { Up = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Word"),
  },
  -- Turn on the mouse wheel to scroll the screen
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "NONE",
    action = act.ScrollByCurrentEventWheelDelta,
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = "NONE",
    action = act.ScrollByCurrentEventWheelDelta,
  },
}

return {
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  leader = { key = "Space", mods = mod.SUPER_REV },
  keys = keys,
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
