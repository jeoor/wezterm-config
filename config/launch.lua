local platform = require("utils.platform")

local options = { default_prog = {}, launch_menu = {} }

if platform.is_win then
  options.default_prog = { "nu" }
  options.launch_menu = {
    { label = "󰍲 Pwsh", args = { "pwsh", "-nologo" } },
    { label = "󰍲 PowerShell", args = { "powershell", "-nologo" } },
    { label = "󰍲 Cmd", args = { "cmd", "/k" } },
    { label = " Nushell", args = { "nu" } },
    { label = "󰣇 Arch", args = { "wsl" } },
    { label = " Ubuntu", args = { "wsl", "-d", "Ubuntu-22.04" } },
    { label = " GitBash", args = { "D:/Scoop/apps/git/current/bin/bash.exe" } },
    { label = "󰌽 MSYS2 UCRT", args = { "cmd", "/c", "D:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64" } },
  }
end

return options
