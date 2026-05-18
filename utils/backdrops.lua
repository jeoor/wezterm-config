local wezterm = require("wezterm")
local colors = require("colors.custom")

math.randomseed(os.time()); math.random(); math.random(); math.random()

local BackDrops = {}
BackDrops.__index = BackDrops

function BackDrops:init()
  return setmetatable({ current_idx = 1, images = {}, images_dir = wezterm.config_dir .. "/backdrops/", no_img = false }, self)
end

function BackDrops:set_images_dir(path)
  self.images_dir = path:match("/$") and path or path .. "/"
  return self
end

function BackDrops:scan_images_dir()
  self.images = wezterm.glob(self.images_dir .. "*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga}")
  return self
end

function BackDrops:random(window)
  self.current_idx = #self.images > 0 and math.random(#self.images) or 1
  if window then window:set_config_overrides({ background = self:_gen_opts(), enable_tab_bar = window:effective_config().enable_tab_bar }) end
  return self
end

function BackDrops:_gen_opts()
  local bg = {}
  if #self.images > 0 then
    table.insert(bg, { source = { File = self.images[self.current_idx] }, horizontal_align = "Center" })
  end
  table.insert(bg, { source = { Color = colors.background }, height = "120%", width = "120%", vertical_offset = "-10%", horizontal_offset = "-10%", opacity = 0.95 })
  return bg
end

function BackDrops:_gen_no_img_opts()
  return { { source = { Color = colors.background }, height = "120%", width = "120%", vertical_offset = "-10%", horizontal_offset = "-10%", opacity = 1 } }
end

function BackDrops:initial_options(opts)
  self.no_img = opts and opts.no_img or false
  return self.no_img and self:_gen_no_img_opts() or self:_gen_opts()
end

function BackDrops:choices()
  local choices = {}
  for idx, file in ipairs(self.images) do
    table.insert(choices, { id = tostring(idx), label = file:match("([^/\\]+)$") })
  end
  return choices
end

function BackDrops:cycle_forward(window)
  if #self.images == 0 then return end
  self.current_idx = self.current_idx >= #self.images and 1 or self.current_idx + 1
  window:set_config_overrides({ background = self:_gen_opts(), enable_tab_bar = window:effective_config().enable_tab_bar })
end

function BackDrops:cycle_back(window)
  if #self.images == 0 then return end
  self.current_idx = self.current_idx <= 1 and #self.images or self.current_idx - 1
  window:set_config_overrides({ background = self:_gen_opts(), enable_tab_bar = window:effective_config().enable_tab_bar })
end

function BackDrops:set_img(window, idx)
  if idx < 1 or idx > #self.images then return end
  self.current_idx = idx
  window:set_config_overrides({ background = self:_gen_opts(), enable_tab_bar = window:effective_config().enable_tab_bar })
end

function BackDrops:toggle_focus(window)
  self.no_img = not self.no_img
  window:set_config_overrides({ background = self.no_img and self:_gen_no_img_opts() or self:_gen_opts(), enable_tab_bar = window:effective_config().enable_tab_bar })
end

return BackDrops:init()
