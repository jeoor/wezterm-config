local platform = require("utils.platform")

local options = { default_prog = {}, launch_menu = {} }

if platform.is_win then
  options.default_prog = { "nu" }
  options.launch_menu = {
    { label = " Nushell", args = { "nu" } },
    { label = "󰨊 Pwsh", args = { "pwsh", "-nologo" } },
    { label = " PowerShell", args = { "powershell", "-nologo" } },
    { label = " Cmd", args = { "cmd", "/k" } },
    { label = " GitBash", args = { "D:/Scoop/apps/git/current/bin/bash.exe" } },
    { label = "󰌽 MSYS2 UCRT", args = { "cmd", "/c", "D:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64" } },
  }
elseif platform.is_mac then
  options.default_prog = { "/opt/homebrew/bin/nu", "-l" }
  options.launch_menu = {
    { label = " Nushell", args = { "/opt/homebrew/bin/nu", "-l" } },
    { label = "󰯅 Bash", args = { "bash", "-l" } },
    { label = "󰕴 Zsh", args = { "zsh", "-l" } },
    { label = "󰈺 Fish", args = { "/opt/homebrew/bin/fish", "-l" } },
  }
elseif platform.is_linux then
  options.default_prog = { "nu" }
  options.launch_menu = {
    { label = " Nushell", args = { "nu" } },
    { label = "󰯅 Bash", args = { "bash", "-l" } },
    { label = "󰕴 Zsh", args = { "zsh", "-l" } },
    { label = "󰈺 Fish", args = { "fish", "-l" } },
  }
end

return options
