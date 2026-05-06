local platform = require("utils.platform")()

local options = {
  default_prog = {},
  launch_menu = {},
}

if platform.is_win then
  options.default_prog = { "nu" }
  options.launch_menu = {
    { label = "󰍲 PowerShell", args = { "powershell", "-nologo" } },
    { label = "󰍲 Cmd", args = { "cmd" } },
    { label = " Nushell", args = { "nu" } },
    { label = "󰣇 Arch", args = { "wsl" } },
    { label = " Ubuntu", args = { "wsl", "-d", "Ubuntu-22.04" } },
    {
      label = " GitBash",
      args = { "D:/Scoop/apps/git/current/bin/bash.exe" },
    },
    {
      label = "󰌽 MSYS2 UCRT",
      args = {
        "cmd",
        "/c",
        "D:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64"
      },
    },
  }
elseif platform.is_mac then
  options.default_prog = { "/opt/homebrew/bin/fish", "--login" }
  options.launch_menu = {
    { label = " Bash", args = { "bash", "--login" } },
    { label = " Fish", args = { "/opt/homebrew/bin/fish", "--login" } },
    { label = " Nushell", args = { "/opt/homebrew/bin/nu", "--login" } },
    { label = " Zsh", args = { "zsh", "--login" } },
  }
elseif platform.is_linux then
  options.default_prog = { "bash", "--login" }
  options.launch_menu = {
    { label = " Bash", args = { "bash", "--login" } },
    { label = " Fish", args = { "/opt/homebrew/bin/fish", "--login" } },
    { label = " Nushell", args = { "/opt/homebrew/bin/nu", "--login" } },
    { label = " Zsh", args = { "zsh", "--login" } },
  }
end

return options
