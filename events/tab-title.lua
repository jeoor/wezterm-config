local wezterm = require("wezterm")
local ustr = require("utils.str")
local nf = wezterm.nerdfonts

-- stylua: ignore
local process_icons = {
  cmd         = utf8.char(0xe62a),  powershell  = utf8.char(0xe70f),
  pwsh        = utf8.char(0xe70f),  nu          = utf8.char(0xe7a8),
  elvish      = utf8.char(0xfc6f),  yori        = utf8.char(0xf1d4),
  nya         = utf8.char(0xf61a),  wsl         = utf8.char(0xf83c),
  bash        = utf8.char(0xf83c),  zsh         = utf8.char(0xf83c),
  fish        = utf8.char(0xf83c),  sh          = utf8.char(0xf83c),
  vim         = utf8.char(0xe62b),  nvim        = utf8.char(0xe62b),
  vi          = utf8.char(0xe62b),  less        = utf8.char(0xf718),
  more        = utf8.char(0xf718),  python      = utf8.char(0xf820),
  node        = utf8.char(0xe74e),  deno        = utf8.char(0xe628),
}

-- stylua: ignore
local ICON_PREFIX = {
  admin    = nf.md_shield_half_full,
  wsl      = nf.cod_terminal_linux,
  debug    = nf.fa_bug,
  select   = nf.md_selection_search,
  edit     = nf.fa_edit,
}

-- stylua: ignore
local ICON_UNSEEN = {
  circle = nf.fa_circle,
  numbered_box_1  = nf.md_numeric_1_box_multiple,  numbered_box_2  = nf.md_numeric_2_box_multiple,
  numbered_box_3  = nf.md_numeric_3_box_multiple,  numbered_box_4  = nf.md_numeric_4_box_multiple,
  numbered_box_5  = nf.md_numeric_5_box_multiple,  numbered_box_6  = nf.md_numeric_6_box_multiple,
  numbered_box_7  = nf.md_numeric_7_box_multiple,  numbered_box_8  = nf.md_numeric_8_box_multiple,
  numbered_box_9  = nf.md_numeric_9_box_multiple,  numbered_box_10 = nf.md_numeric_9_plus_box_multiple,
  numbered_circle_1  = nf.md_numeric_1_circle,  numbered_circle_2  = nf.md_numeric_2_circle,
  numbered_circle_3  = nf.md_numeric_3_circle,  numbered_circle_4  = nf.md_numeric_4_circle,
  numbered_circle_5  = nf.md_numeric_5_circle,  numbered_circle_6  = nf.md_numeric_6_circle,
  numbered_circle_7  = nf.md_numeric_7_circle,  numbered_circle_8  = nf.md_numeric_8_circle,
  numbered_circle_9  = nf.md_numeric_9_circle,  numbered_circle_10 = nf.md_numeric_9_plus_circle,
}

local GLYPH_SEMI_CIRCLE_LEFT = utf8.char(0xe0b6)
local GLYPH_SEMI_CIRCLE_RIGHT = utf8.char(0xe0b4)

local M = {}

M.cells = {}

M.colors = {
  default = { bg = "#363b54", fg = "#1a1b26" },
  is_active = { bg = "#7aa2f7", fg = "#1A1B26" },
  hover = { bg = "#a9b1d6", fg = "#1A1B26" },
}

-- stylua: ignore
local ICON_PROGRESS_PCT = {
  nf.md_circle_slice_1, nf.md_circle_slice_2, nf.md_circle_slice_3, nf.md_circle_slice_4,
  nf.md_circle_slice_5, nf.md_circle_slice_6, nf.md_circle_slice_7, nf.md_circle_slice_8,
}
-- stylua: ignore
local ICON_PROGRESS_IND = { "◜", "◠", "◝", "◞", "◡", "◟" }

local PROGRESS_MIN_VERSION = 20250209
local PROGRESS_STALE_AFTER = 30

local function clean_process_name(proc)
  if not proc then return "" end
  local a = string.gsub(proc, ".*[/\\](.*)", "%1")
  if ustr.ends_with(a, ".exe") then a = a:sub(1, -5) end
  return a
end

local function pct_to_frame(pct)
  local idx = math.max(1, math.floor(pct * #ICON_PROGRESS_PCT / 100))
  return ICON_PROGRESS_PCT[idx]
end

local ind_frame = 1
local function ind_to_frame()
  local frame = ind_frame
  ind_frame = (ind_frame % #ICON_PROGRESS_IND) + 1
  return ICON_PROGRESS_IND[frame]
end

local function create_base_title(pane_title, process_name)
  local prefix_icon = nil
  local base_title = pane_title

  if base_title == "Debug" then
    prefix_icon = ICON_PREFIX.debug
    base_title = base_title:upper()
  elseif base_title == "Launcher" then
    prefix_icon = ICON_PREFIX.launcher
    base_title = base_title:upper()
  elseif
    ustr.starts_with(base_title, "Administrator:") or ustr.ends_with(base_title, "(Admin)")
  then
    prefix_icon = ICON_PREFIX.admin
    base_title = base_title:gsub("Administrator: ", ""):gsub("%(Admin%)", "")
  elseif ustr.starts_with(process_name, "wsl") then
    prefix_icon = ICON_PREFIX.wsl
  elseif ustr.starts_with(base_title, "InputSelector:") then
    prefix_icon = ICON_PREFIX.select
    base_title = base_title:gsub("InputSelector: ", "")
  elseif ustr.starts_with(base_title, "InputLine:") then
    prefix_icon = ICON_PREFIX.edit
    base_title = base_title:gsub("InputLine: ", "")
  end

  if not prefix_icon then
    prefix_icon = process_icons[process_name]
  end

  return base_title, prefix_icon
end

local function create_title(process_name, base_title, max_width, inset)
  local title
  if process_name:len() > 0 then
    if base_title:len() > 0 then
      title = process_name .. "  " .. base_title
    else
      title = process_name
    end
  else
    title = base_title
  end

  local cw = wezterm.column_width
  local available = max_width - inset
  if cw(title) > available then
    local trunc = math.max(1, available - cw(".."))
    title = wezterm.truncate_right(title, trunc) .. ".."
  end
  return title
end

-- Original M.push with color-swap support for semi-circles
M.push = function(bg, fg, attribute, text)
  table.insert(M.cells, { Background = { Color = bg } })
  table.insert(M.cells, { Foreground = { Color = fg } })
  table.insert(M.cells, { Attribute = attribute })
  table.insert(M.cells, { Text = text })
  table.insert(M.cells, "ResetAttributes")
end

local progress_stale = (function()
  local status_score = { indeterminate = 100, error = 200, percentage = 300 }
  local entries = {}
  local CLEANUP_INTERVAL = 300  -- 5 minutes
  local last_cleanup = os.time()

  return function(tab_index, pane_index, status, pct)
    local entry_id = (tab_index << 5) | pane_index
    local now = os.time()

    -- Periodic cleanup of stale entries
    if now - last_cleanup > CLEANUP_INTERVAL then
      for id, entry in pairs(entries) do
        if now - entry.last_changed > CLEANUP_INTERVAL then
          entries[id] = nil
        end
      end
      last_cleanup = now
    end

    if not entries[entry_id] then
      entries[entry_id] = { sum = status_score[status] + pct, last_changed = now }
      return false
    end
    local sum = status_score[status] + pct
    if sum ~= entries[entry_id].sum then
      entries[entry_id].sum = sum
      entries[entry_id].last_changed = now
      return false
    end
    return now - entries[entry_id].last_changed > PROGRESS_STALE_AFTER
  end
end)()

local function check_progress(tab_index, panes)
  local progress = {}
  for _, pane in ipairs(panes) do
    if #progress > 3 then break end
    local prog = pane.progress
    local status, icon, pct

    if prog == "Indeterminate" then
      status, icon, pct = "indeterminate", ind_to_frame(), 0
    elseif prog and prog.Percentage ~= nil then
      status, icon, pct = "percentage", pct_to_frame(prog.Percentage), prog.Percentage
    elseif prog and prog.Error ~= nil then
      status, icon, pct = "error", pct_to_frame(prog.Error), prog.Error
    end

    if icon and status and not progress_stale(tab_index, pane.pane_index, status, pct) then
      table.insert(progress, { icon = icon, status = status })
    end
  end
  return progress
end

local function check_unseen_output(is_active, panes, opts)
  if opts.hide_active_tab_unseen and is_active then return nil end
  local count = 0
  local limit = opts.unseen_icon == "circle" and 0 or 10
  for _, pane in ipairs(panes) do
    if count > limit then break end
    if pane.has_unseen_output ~= nil and pane.has_unseen_output then
      count = count + 1
    end
  end
  if count > 0 then
    if opts.unseen_icon == "circle" then
      return ICON_UNSEEN.circle
    end
    return ICON_UNSEEN[opts.unseen_icon .. "_" .. count] or ICON_UNSEEN.circle
  end
  return nil
end

M.setup = function(opts)
  opts = opts or {}
  local event_opts = {
    hide_active_tab_unseen = opts.hide_active_tab_unseen ~= nil and opts.hide_active_tab_unseen or true,
    unseen_icon = opts.unseen_icon or "numbered_box",
    show_progress = opts.show_progress ~= nil and opts.show_progress or true,
  }

  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    M.cells = {}

    local bg, fg
    local process_name = clean_process_name(tab.active_pane.foreground_process_name)
    local base_title, prefix_icon = create_base_title(tab.active_pane.title, process_name)
    local unseen_icon = check_unseen_output(tab.is_active, tab.panes, event_opts)
    local progress = event_opts.show_progress and check_progress(tab.tab_index, tab.panes) or {}
    local right_width = 2 + (#progress * 2) + (unseen_icon and 2 or 0)
    local left_width = 1 + (prefix_icon and 2 or 0)
    local inset = left_width + right_width + 1

    if tab.is_active then
      bg = M.colors.is_active.bg
      fg = M.colors.is_active.fg
    elseif hover then
      bg = M.colors.hover.bg
      fg = M.colors.hover.fg
    else
      bg = M.colors.default.bg
      fg = M.colors.default.fg
    end

    local title = create_title(process_name, base_title, max_width, inset)

    -- Left semi-circle (color-swapped: transparent=fg, solid=bg)
    M.push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_LEFT)

    -- Prefix icon (admin/wsl/debug/process)
    if prefix_icon then
      M.push(bg, fg, { Intensity = "Bold" }, prefix_icon .. " ")
    end

    -- Title
    M.push(bg, fg, { Intensity = "Bold" }, " " .. title)

    -- Progress indicator (color by status)
    local progress_colors = { percentage = "#9df296", error = "#f7768e", indeterminate = "#a9b1d6" }
    for _, prog in ipairs(progress) do
      M.push(bg, progress_colors[prog.status] or "#9df296", { Intensity = "Bold" }, " " .. prog.icon)
    end

    -- Unseen output alert
    if unseen_icon then
      M.push(bg, "#7dcfff", { Intensity = "Bold" }, "  " .. unseen_icon)
    end

    -- Right padding + right semi-circle (color-swapped)
    M.push(bg, fg, { Intensity = "Bold" }, " ")
    M.push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_RIGHT)

    return M.cells
  end)

  wezterm.on("tabs.toggle-tab-bar", function(window, _pane)
    local cfg = window:effective_config()
    window:set_config_overrides({
      enable_tab_bar = not cfg.enable_tab_bar,
      background = cfg.background,
    })
  end)
end

return M
