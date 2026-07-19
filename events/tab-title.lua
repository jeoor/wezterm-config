-- Kevin-style stateful tab renderer with the existing visual contract.
local wezterm = require("wezterm")
local Cells = require("utils.cells")
local OptsValidator = require("utils.opts-validator")
local ustr = require("utils.str")

local nf = wezterm.nerdfonts
local attr = Cells.attr

---@class Event.TabTitleOptionsInput
---@field unseen_icon? "circle"|"numbered_circle"|"numbered_box"
---@field hide_active_tab_unseen? boolean
---@field show_progress? boolean

---@class Event.TabTitleOptions
---@field unseen_icon "circle"|"numbered_circle"|"numbered_box"
---@field hide_active_tab_unseen boolean
---@field show_progress boolean

local EVENT_OPTS = OptsValidator:new({
  {
    name = "unseen_icon",
    type = "string",
    enum = { "circle", "numbered_circle", "numbered_box" },
    default = "numbered_box",
  },
  { name = "hide_active_tab_unseen", type = "boolean", default = true },
  { name = "show_progress", type = "boolean", default = true },
})

local M = {}

local PROGRESS_MIN_VERSION = 20250209
local PROGRESS_STALE_AFTER = 30
local PROGRESS_CLEANUP_INTERVAL = 300
local MAX_PROGRESS_ITEMS = 4
local MAX_UNSEEN_COUNT = 10
local CLOSE_BUTTON_WIDTH = 2

local GLYPH_SEMI_CIRCLE_LEFT = utf8.char(0xe0b6)
local GLYPH_SEMI_CIRCLE_RIGHT = utf8.char(0xe0b4)

-- stylua: ignore
local PROCESS_ICONS = {
  cmd         = nf.cod_terminal_cmd,         powershell = nf.cod_terminal_powershell,
  pwsh        = nf.cod_terminal_powershell,  nu         = nf.cod_terminal,
  elvish      = nf.cod_terminal,             yori       = nf.cod_terminal,
  nya         = nf.cod_terminal,             wsl        = nf.fa_linux,
  bash        = nf.cod_terminal_bash,        zsh        = nf.cod_terminal_zsh,
  fish        = nf.cod_terminal,             sh         = nf.cod_terminal,
  vim         = nf.seti_vim,                 nvim       = nf.seti_vim,
  vi          = nf.seti_vim,                 less       = nf.fa_file,
  more        = nf.fa_file,                  python     = nf.dev_python,
  node        = nf.fa_node_js,               deno       = nf.cod_globe,
}

-- stylua: ignore
local ICON_PREFIX = {
  admin    = nf.md_shield_half_full,
  wsl      = nf.cod_terminal_linux,
  debug    = nf.fa_bug,
  launcher = nf.cod_terminal,
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

-- stylua: ignore
local ICON_PROGRESS_PCT = {
  nf.md_circle_slice_1, nf.md_circle_slice_2, nf.md_circle_slice_3, nf.md_circle_slice_4,
  nf.md_circle_slice_5, nf.md_circle_slice_6, nf.md_circle_slice_7, nf.md_circle_slice_8,
}

-- stylua: ignore
local ICON_PROGRESS_IND = { "◜", "◠", "◝", "◞", "◡", "◟" }

-- stylua: ignore
local SEGMENT = {
  scircle_left  = 1,
  icon          = 2,
  title         = 3,
  progress      = 4,
  unseen_output = 5,
  padding       = 6,
  scircle_right = 7,
  close_gutter  = 8,
}

-- Each variant preserves the existing visual order and spacing.
-- stylua: ignore
local VARIANT = {
  { SEGMENT.scircle_left, SEGMENT.title, SEGMENT.padding, SEGMENT.scircle_right, SEGMENT.close_gutter },
  {
    SEGMENT.scircle_left,
    SEGMENT.title,
    SEGMENT.unseen_output,
    SEGMENT.padding,
    SEGMENT.scircle_right,
    SEGMENT.close_gutter,
  },
  {
    SEGMENT.scircle_left,
    SEGMENT.title,
    SEGMENT.progress,
    SEGMENT.padding,
    SEGMENT.scircle_right,
    SEGMENT.close_gutter,
  },
  {
    SEGMENT.scircle_left,
    SEGMENT.title,
    SEGMENT.progress,
    SEGMENT.unseen_output,
    SEGMENT.padding,
    SEGMENT.scircle_right,
    SEGMENT.close_gutter,
  },
  { SEGMENT.scircle_left, SEGMENT.icon, SEGMENT.title, SEGMENT.padding, SEGMENT.scircle_right, SEGMENT.close_gutter },
  {
    SEGMENT.scircle_left,
    SEGMENT.icon,
    SEGMENT.title,
    SEGMENT.unseen_output,
    SEGMENT.padding,
    SEGMENT.scircle_right,
    SEGMENT.close_gutter,
  },
  {
    SEGMENT.scircle_left,
    SEGMENT.icon,
    SEGMENT.title,
    SEGMENT.progress,
    SEGMENT.padding,
    SEGMENT.scircle_right,
    SEGMENT.close_gutter,
  },
  {
    SEGMENT.scircle_left,
    SEGMENT.icon,
    SEGMENT.title,
    SEGMENT.progress,
    SEGMENT.unseen_output,
    SEGMENT.padding,
    SEGMENT.scircle_right,
    SEGMENT.close_gutter,
  },
}

-- These are the current colors; only their organization changed.
-- stylua: ignore
local COLORS = {
  text_default = { bg = "#363b54", fg = "#1a1b26" },
  text_active  = { bg = "#7aa2f7", fg = "#1A1B26" },
  text_hover   = { bg = "#a9b1d6", fg = "#1A1B26" },

  scircle_default = { bg = "#1a1b26", fg = "#363b54" },
  scircle_active  = { bg = "#1A1B26", fg = "#7aa2f7" },
  scircle_hover   = { bg = "#1A1B26", fg = "#a9b1d6" },

  gutter_default = { bg = "#1a1b26", fg = "#1a1b26" },
  gutter_active  = { bg = "#1A1B26", fg = "#1A1B26" },
  gutter_hover   = { bg = "#1A1B26", fg = "#1A1B26" },

  unseen_output_default = { bg = "#363b54", fg = "#7dcfff" },
  unseen_output_active  = { bg = "#7aa2f7", fg = "#7dcfff" },
  unseen_output_hover   = { bg = "#a9b1d6", fg = "#7dcfff" },

  progress_percentage_default    = { bg = "#363b54", fg = "#9df296" },
  progress_percentage_active     = { bg = "#7aa2f7", fg = "#9df296" },
  progress_percentage_hover      = { bg = "#a9b1d6", fg = "#9df296" },
  progress_error_default         = { bg = "#363b54", fg = "#f7768e" },
  progress_error_active          = { bg = "#7aa2f7", fg = "#f7768e" },
  progress_error_hover           = { bg = "#a9b1d6", fg = "#f7768e" },
  progress_indeterminate_default = { bg = "#363b54", fg = "#a9b1d6" },
  progress_indeterminate_active  = { bg = "#7aa2f7", fg = "#a9b1d6" },
  progress_indeterminate_hover   = { bg = "#a9b1d6", fg = "#a9b1d6" },
}

local function pct_to_frame(pct)
  pct = tonumber(pct) or 0
  local index = math.max(1, math.min(#ICON_PROGRESS_PCT, math.floor(pct * #ICON_PROGRESS_PCT / 100)))
  return ICON_PROGRESS_PCT[index]
end

local indeterminate_frame = 1
local function ind_to_frame()
  local frame = indeterminate_frame
  indeterminate_frame = (indeterminate_frame % #ICON_PROGRESS_IND) + 1
  return ICON_PROGRESS_IND[frame]
end

---@param process string?
local function clean_process_name(process)
  if not process then return "" end
  local name = process:gsub(".*[/\\](.*)", "%1")
  return ustr.ends_with(name, ".exe") and name:sub(1, -5) or name
end

---@param pane_title string
---@param process_name string
---@return string, string?
local function create_base_title(pane_title, process_name)
  local prefix_icon
  local base_title = pane_title

  if base_title == "Debug" then
    prefix_icon = ICON_PREFIX.debug
    base_title = base_title:upper()
  elseif base_title == "Launcher" then
    prefix_icon = ICON_PREFIX.launcher
    base_title = base_title:upper()
  elseif ustr.starts_with(base_title, "Administrator:") or ustr.ends_with(base_title, "(Admin)") then
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

  return base_title, prefix_icon or PROCESS_ICONS[process_name]
end

local function create_title(process_name, base_title, max_width, inset)
  local title
  if process_name:len() > 0 then
    title = base_title:len() > 0 and process_name .. "  " .. base_title or process_name
  else
    title = base_title
  end

  local width = wezterm.column_width
  local available = math.max(0, max_width - inset)
  if width(title) <= available then return title end

  local ellipsis = ".."
  if available <= width(ellipsis) then
    return available > 0 and wezterm.truncate_right(title, available) or ""
  end
  return wezterm.truncate_right(title, available - width(ellipsis)) .. ellipsis
end

local progress_stale = (function()
  local status_score = { indeterminate = 100, error = 200, percentage = 300 }
  local entries = {}
  local last_cleanup = os.time()

  return function(pane_id, status, pct)
    local now = os.time()

    if now - last_cleanup > PROGRESS_CLEANUP_INTERVAL then
      for id, entry in pairs(entries) do
        if now - entry.last_changed > PROGRESS_CLEANUP_INTERVAL then entries[id] = nil end
      end
      last_cleanup = now
    end

    local sum = status_score[status] + pct
    local entry = entries[pane_id]
    if not entry or entry.sum ~= sum then
      entries[pane_id] = { sum = sum, last_changed = now }
      return false
    end
    return now - entry.last_changed > PROGRESS_STALE_AFTER
  end
end)()

---@param options Event.TabTitleOptions
---@param panes PaneInformation[]
local function check_progress(options, panes)
  if not options.show_progress then return {} end

  local progress = {}
  for _, pane in ipairs(panes) do
    if #progress >= MAX_PROGRESS_ITEMS then break end
    local prog = pane.progress
    local status, icon, pct

    if prog == "Indeterminate" then
      status, icon, pct = "indeterminate", ind_to_frame(), 0
    elseif prog and prog.Percentage ~= nil then
      status, icon, pct = "percentage", pct_to_frame(prog.Percentage), prog.Percentage
    elseif prog and prog.Error ~= nil then
      status, icon, pct = "error", pct_to_frame(prog.Error), prog.Error
    end

    pct = tonumber(pct) or 0
    if icon and status and not progress_stale(pane.pane_id, status, pct) then
      table.insert(progress, { icon = icon, status = status })
    end
  end
  return progress
end

---@param options Event.TabTitleOptions
---@param is_active boolean
---@param panes PaneInformation[]
local function check_unseen_output(options, is_active, panes)
  if options.hide_active_tab_unseen and is_active then return nil end

  local count = 0
  for _, pane in ipairs(panes) do
    if pane.has_unseen_output then
      count = count + 1
      if options.unseen_icon == "circle" or count >= MAX_UNSEEN_COUNT then break end
    end
  end

  if count == 0 then return nil end
  if options.unseen_icon == "circle" then return ICON_UNSEEN.circle end
  return ICON_UNSEEN[options.unseen_icon .. "_" .. count] or ICON_UNSEEN.circle
end

local function fixed_width(prefix_icon, progress, unseen_icon)
  local width = wezterm.column_width
  local inset = width(GLYPH_SEMI_CIRCLE_LEFT)
    + width(" ")
    + width(" ")
    + width(GLYPH_SEMI_CIRCLE_RIGHT)
    + CLOSE_BUTTON_WIDTH

  if prefix_icon then inset = inset + width(prefix_icon .. " ") end
  for _, item in ipairs(progress) do inset = inset + width(" " .. item.icon) end
  if unseen_icon then inset = inset + width("  " .. unseen_icon) end
  return inset
end

local bold = attr(attr.intensity("Bold"))
local progress_cells = Cells:new():add_segment(SEGMENT.progress, nil, nil, bold)
local title_cells = Cells:new()
  :add_segment(SEGMENT.scircle_left, GLYPH_SEMI_CIRCLE_LEFT, nil, bold)
  :add_segment(SEGMENT.icon, nil, nil, bold)
  :add_segment(SEGMENT.title, nil, nil, bold)
  :add_nested_segment(SEGMENT.progress)
  :add_segment(SEGMENT.unseen_output, nil, nil, bold)
  :add_segment(SEGMENT.padding, " ", nil, bold)
  :add_segment(SEGMENT.scircle_right, GLYPH_SEMI_CIRCLE_RIGHT, nil, bold)
  :add_segment(SEGMENT.close_gutter, string.rep(" ", CLOSE_BUTTON_WIDTH), nil, bold)

---@class Tab
---@field has_icon boolean
---@field has_unseen boolean
---@field has_progress boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
  return setmetatable({
    has_icon = false,
    has_unseen = false,
    has_progress = false,
  }, self)
end

---@param options Event.TabTitleOptions
---@param tab TabInformation
---@param hover boolean
---@param max_width number
function Tab:update_cells(options, tab, hover, max_width)
  local state = tab.is_active and "active" or hover and "hover" or "default"
  local process_name = clean_process_name(tab.active_pane.foreground_process_name)
  local base_title, prefix_icon = create_base_title(tab.active_pane.title or "", process_name)
  local unseen_icon = check_unseen_output(options, tab.is_active, tab.panes)
  local progress = check_progress(options, tab.panes)

  if tab.tab_title and tab.tab_title ~= "" then
    process_name = ""
    base_title = tab.tab_title
  end

  self.has_icon = prefix_icon ~= nil
  self.has_unseen = unseen_icon ~= nil
  self.has_progress = #progress > 0

  title_cells
    :update_segment_text(SEGMENT.icon, prefix_icon and prefix_icon .. " " or "")
    :update_segment_text(SEGMENT.title, " " .. create_title(
      process_name,
      base_title,
      max_width,
      fixed_width(prefix_icon, progress, unseen_icon)
    ))
    :update_segment_text(SEGMENT.unseen_output, unseen_icon and "  " .. unseen_icon or "")

  local progress_items = {}
  for _, item in ipairs(progress) do
    progress_cells
      :update_segment_text(SEGMENT.progress, " " .. item.icon)
      :update_segment_colors(SEGMENT.progress, COLORS["progress_" .. item.status .. "_" .. state])
    table.insert(progress_items, progress_cells:render({ SEGMENT.progress }))
  end
  title_cells:update_nested_segment(SEGMENT.progress, progress_items)

  title_cells
    :update_segment_colors(SEGMENT.scircle_left, COLORS["scircle_" .. state])
    :update_segment_colors(SEGMENT.icon, COLORS["text_" .. state])
    :update_segment_colors(SEGMENT.title, COLORS["text_" .. state])
    :update_segment_colors(SEGMENT.unseen_output, COLORS["unseen_output_" .. state])
    :update_segment_colors(SEGMENT.padding, COLORS["text_" .. state])
    :update_segment_colors(SEGMENT.scircle_right, COLORS["scircle_" .. state])
    :update_segment_colors(SEGMENT.close_gutter, COLORS["gutter_" .. state])
end

function Tab:render()
  local variant = self.has_icon and 5 or 1
  if self.has_unseen then variant = variant + 1 end
  if self.has_progress then variant = variant + 2 end
  return title_cells:render(VARIANT[variant])
end

local renderer = Tab:new()

---@param opts? Event.TabTitleOptionsInput
function M.setup(opts)
  local options, err = EVENT_OPTS:validate(opts or {})
  if err then wezterm.log_error(err) end

  local version = tonumber(wezterm.version:match("^(%d+)") or "")
  if not version or version < PROGRESS_MIN_VERSION then options.show_progress = false end

  wezterm.on("tabs.manual-update-tab-title", function(window, pane)
    window:perform_action(
      wezterm.action.PromptInputLine({
        description = wezterm.format({
          { Foreground = { Color = "#FFFFFF" } },
          { Attribute = { Intensity = "Bold" } },
          { Text = "Enter new name for tab" },
        }),
        action = wezterm.action_callback(function(callback_window, _, line)
          if line ~= nil then callback_window:active_tab():set_title(line) end
        end),
      }),
      pane
    )
  end)

  wezterm.on("tabs.reset-tab-title", function(window, _pane)
    window:active_tab():set_title("")
  end)

  wezterm.on("tabs.toggle-tab-bar", function(window, _pane)
    local config = window:effective_config()
    local overrides = window:get_config_overrides() or {}
    overrides.enable_tab_bar = not config.enable_tab_bar
    window:set_config_overrides(overrides)
  end)

  wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
    renderer:update_cells(options, tab, hover, max_width)
    return renderer:render()
  end)
end

return M
