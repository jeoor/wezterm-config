local attr = {}
attr.intensity = function(t) return { Attribute = { Intensity = t } } end
attr.italic = function() return { Attribute = { Italic = true } } end
attr.underline = function(t) return { Attribute = { Underline = t } } end

local Cells = {}
Cells.__index = Cells
Cells.attr = setmetatable(attr, { __call = function(_, ...) return { ... } end })

function Cells:new() return setmetatable({ segments = {} }, self) end

function Cells:add_segment(id, text, color, attributes)
  color = color or {}
  local items = {}
  if color.bg then table.insert(items, { Background = { Color = color.bg } }) end
  if color.fg then table.insert(items, { Foreground = { Color = color.fg } }) end
  if attributes then for _, a in ipairs(attributes) do table.insert(items, a) end end
  table.insert(items, { Text = text or "" })
  table.insert(items, "ResetAttributes")
  self.segments[id] = { items = items, has_bg = color.bg ~= nil, has_fg = color.fg ~= nil, nested = false }
  return self
end

function Cells:add_nested_segment(id, items)
  self.segments[id] = { nested_items = items or {}, nested = true }
  return self
end

function Cells:update_text(id, text)
  self.segments[id].items[#self.segments[id].items - 1] = { Text = text }
  return self
end

function Cells:update_colors(id, color)
  local s = self.segments[id]
  if color.bg then
    if color.bg == "UNSET" then
      if s.has_bg then table.remove(s.items, 1); s.has_bg = false end
    elseif s.has_bg then s.items[1] = { Background = { Color = color.bg } }
    else table.insert(s.items, 1, { Background = { Color = color.bg } }); s.has_bg = true end
  end
  if color.fg then
    local idx = s.has_bg and 2 or 1
    if color.fg == "UNSET" then
      if s.has_fg then table.remove(s.items, idx); s.has_fg = false end
    elseif s.has_fg then s.items[idx] = { Foreground = { Color = color.fg } }
    else table.insert(s.items, idx, { Foreground = { Color = color.fg } }); s.has_fg = true end
  end
  return self
end

function Cells:update_nested(id, items) self.segments[id].nested_items = items; return self end

function Cells:render(ids)
  local out = {}
  for _, id in ipairs(ids) do
    local s = self.segments[id]
    if s.nested then
      for _, n in ipairs(s.nested_items) do for _, item in ipairs(n) do table.insert(out, item) end end
    else
      for _, item in ipairs(s.items) do table.insert(out, item) end
    end
  end
  return out
end

function Cells:render_all()
  local out = {}
  for _, s in pairs(self.segments) do
    if s.nested then
      for _, n in ipairs(s.nested_items) do for _, item in ipairs(n) do table.insert(out, item) end end
    else
      for _, item in ipairs(s.items) do table.insert(out, item) end
    end
  end
  return out
end

return Cells
