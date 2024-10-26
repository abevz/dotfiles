local wez = require "wezterm" ---@class WezTerm
local fun = require "utils.fun" ---@class Fun
local icons = require "utils.icons" ---@class Icons
local tabicons = icons.Separators.TabBar ---@class TabBarIcons
local dylan = require "utils.dylan" ---@class Dylan
-- local inspect = require "utils.inspect" ---@class Inspect

wez.on("format-tab-title", function(tab, _, _, config, hover, max_width)
  if config.use_fancy_tab_bar or not config.enable_tab_bar then
    return
  end

  local theme = require("colors")[fun.get_scheme()]
  local bg = theme.tab_bar.background
  local fg

  local TabTitle = require("utils.layout"):new() ---@class Layout

  local pane, tab_idx = tab.active_pane, tab.tab_index

  -- DUMP the objects available
  -- wez.log_info("Inspected Tab Object: " .. inspect.inspectWezObject(tab))
  -- wez.log_info("Inspected Pane Object: " .. inspect.inspectWezObject(pane))

  -- This event cant access the pane.current_working_dir.file_path its nill

  local attributes = {}

  ---set colors based on states
  if tab.is_active then
    fg = theme.ansi[5]
    attributes = { "Bold" }
  elseif hover then
    fg = theme.selection_bg
  else
    fg = theme.brights[1]
  end

  ---Check if any pane has unseen output
  local unseen_output = false
  for _, p in ipairs(tab.panes) do
    if p.has_unseen_output then
      unseen_output = true
      break
    end
  end

  -- wez.log_info("Tab title of : " .. tab_idx .. " is " .. tab.window_title)
  -- wez.log_info("Pane title is : " .. " " .. pane.title)

  local title = "" ---@type string

  -- IF  there is CWD and foreground process set it take priority
  local program = function()
    -- Check if the properties exist and are not nil
    if
      pane.current_working_dir
      and pane.current_working_dir.file_path
      and pane.foreground_process_name
    then
      -- Additional check if they are not empty strings, if needed
      if
        pane.current_working_dir.file_path ~= "" and pane.foreground_process_name ~= ""
      then
        return dylan.format_title(
          pane.foreground_process_name,
          pane.current_working_dir.file_path,
          max_width,
          config
        )
      end
    end
    -- Handle the case where properties are nil or empty
    return nil
  end

  local programResult = program()
  if programResult then
    -- wez.log_info("Program VALUE : " .. programResult)
    title = programResult
  else
    -- TODO : find something else than process ?
    -- title = pane.Title
  end

  ---add the either the leftmost element or the normal left separator. This is done to
  ---esure a bit of space from the left margin.
  TabTitle:push(bg, fg, tab_idx == 0 and tabicons.leftmost or tabicons.left, attributes)

  ---add the tab number. can be substituted by the `has_unseen_output` notification
  TabTitle:push(
    fg,
    bg,
    (unseen_output and icons.UnseenNotification or icons.Numbers[tab_idx + 1] or "")
      .. " ",
    attributes
  )

  ---the formatted tab title
  TabTitle:push(fg, bg, title, attributes)

  ---the right tab bar separator
  TabTitle:push(bg, fg, icons.Separators.FullBlock .. tabicons.right, attributes)

  return TabTitle
end)
