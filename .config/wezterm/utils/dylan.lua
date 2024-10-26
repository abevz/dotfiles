local wez = require "wezterm" ---@class WezTerm
local act = wez.action ---@class WezTermAction
local fun = require "utils.fun" ---@class Fun
-- local inspect = require "plugins.inspect" ---@class Inspect

---User defined utility functions
---@class Dylan
local M = {}

M.process_substitutions = {
  nvim = wez.nerdfonts.dev_vim,
  node = wez.nerdfonts.dev_vim,
  cmd = wez.nerdfonts.dev_vim,
  ["lua-language-server"] = wez.nerdfonts.dev_vim,
  marksman = wez.nerdfonts.dev_vim,
  pwsh = wez.nerdfonts.md_powershell,
  PowerShell = wez.nerdfonts.md_powershell,
  bash = wez.nerdfonts.md_bash,
  yazi = wez.nerdfonts.md_duck,
  -- Add more key-value pairs as needed
}
--- Formats the title of a process by replacing its path with an icon or the basename.
-- This function takes a path to a process executable and tries to replace it
-- with a corresponding icon based on predefined patterns. If no pattern matches,
-- it defaults to the basename of the process path.
-- @param proc string: The full path to the process executable.
-- @return string: The icon representing the process or its basename if no pattern matches.
-- @usage format_title_process("C:\\Program Files\\PowerShell\\7\\pwsh.exe") -> wez.nerdfonts.md_powershell
-- @usage format_title_process("C:\\Program Files\\nodejs\\node.exe") -> wez.nerdfonts.dev_vim
--
function M.format_title_process(proc)
  local title = fun
    .basename(proc)
    :gsub("%.exe%s?$", "")
    :gsub("^Administrator: %w+", wez.nerdfonts.md_chess_king)
    :gsub("Copy mode: ", "")

  -- Replace patterns with corresponding icons
  for pattern, icon in pairs(M.process_substitutions) do
    title = title:gsub(pattern, icon)
  end
  return title
end

-- NOTE: workaround not great, hardcoded 16 because it work on my screen...
function M.format_title_path(cwd, max_width, config)
  cwd = fun.basename(cwd) or ""
  -- Define the max length for cwd
  local max_cwd_length = 16
  -- if max_width == config.tab_max_width and #cwd > 0 then
  --   --
  --   -- cwd = wez.truncate_right(cwd, max_width - 14) .. "..."
  -- end
  if #cwd > max_cwd_length then
    cwd = wez.truncate_right(cwd, max_cwd_length - 3) .. "..."
  end
  return (" %s"):format(cwd)
end

-- TODO : second pass of formating ??
function M.format_title(proc, cwd, max_width, config)
  local title = ""
  local proc_formatted = M.format_title_process(proc)
  local cwd_formatted = M.format_title_path(cwd, max_width, config)
  title = proc_formatted .. " " .. cwd_formatted
  return title
end

return M
