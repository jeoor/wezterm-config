local platform = require("utils.platform")

local options = {
  wsl_domains = {},
  ssh_domains = {},
  unix_domains = {},
}

if platform.is_win then
  options.wsl_domains = {
    { name = "WSL:Arch", distribution = "Arch", default_cwd = "/home/keao" },
    { name = "WSL:Ubuntu", distribution = "Ubuntu-22.04", default_cwd = "/home/keao" },
  }
end

return options
