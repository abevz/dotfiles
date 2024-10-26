-- Function to get the directory of the current script
-- TODO : this neeed to be done to cleanup the config
local function script_dir()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match "(.*/)"
end

-- Add the current script's directory to the Lua package path
package.path = package.path .. ";" .. script_dir() .. "?.lua"

-- Now require your modules
local appearance = require "appearance"
local font = require "font"
local tabBar = require "tab-bar"
local general = require "general"
-- Merge tables (assuming utils.fun.tbl_merge works as expected)
local utils = require "utils.fun"
return utils.tbl_merge(appearance, font, tabBar, general)
--
-- return require("utils.fun").tbl_merge(
--   -- (require "config.gpu"),
--   (require "appearance"),
--   (require "font"),
--   (require "tab-bar"),
--   (require "general")
-- )
