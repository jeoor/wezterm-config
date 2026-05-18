local backdrops = require("utils.backdrops")
  :scan_images_dir()
  :random()

local Config = require("config")

require("events.backdrops").setup()
require("events.left-status").setup()
require("events.right-status").setup()
require("events.tab-title").setup()
require("events.new-tab-button").setup()
require("events.gui-startup").setup()

return Config:init()
  :append(require("config.appearance"))
  :append({ background = backdrops:initial_options() })
  :append(require("config.bindings"))
  :append(require("config.domains"))
  :append(require("config.fonts"))
  :append(require("config.general"))
  :append(require("config.launch")).options
