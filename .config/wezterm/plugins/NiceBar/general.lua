---@class WezTerm
local wez = require "wezterm"

local icons = require "utils.icons" ---@class Icons
local fun = require "utils.fun" ---@class Fun
local dylan = require "utils.dylan" ---@class Dylan

---@class Config
local Config = {}

local is_windows = wez.target_triple:find "windows" ~= nil

if is_windows then
  Config.default_prog =
    { "pwsh", "-NoLogo", "-ExecutionPolicy", "RemoteSigned", "-NoProfileLoadTime" }

  Config.launch_menu = {
    {
      label = icons.Pwsh .. " PowerShell V7",
      args = {
        "pwsh",
        "-NoLogo",
        "-ExecutionPolicy",
        "RemoteSigned",
        "-NoProfileLoadTime",
      },
      cwd = "~",
    },
    { label = icons.Pwsh .. " PowerShell V5", args = { "powershell" }, cwd = "~" },
    { label = "Command Prompt", args = { "cmd.exe" }, cwd = "~" },
  }

  -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
  Config.wsl_domains = {}
  -- {
  --   {
  --     name = "WSL:Ubuntu",
  --     distribution = "Ubuntu",
  --     username = "sravioli",
  --     default_cwd = "/home/sRavioli",
  --     default_prog = { "bash" },
  --   },
  --   {
  --     name = "WSL:Alpine",
  --     distribution = "Alpine",
  --     username = "sravioli",
  --     default_cwd = "/home/sravioli",
  --   },
  -- }
end

Config.default_cwd = fun.home

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config
