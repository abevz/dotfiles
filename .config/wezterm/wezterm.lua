-- These are the basic's for using wezterm.
-- Mux is the mutliplexes for windows etc inside of the terminal
-- Action is to perform actions on the terminal
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action
local ssh = require "plugins.ssh_menu" ---@class SSH
--local session_manager = require("wezterm-session-manager/session-manager")

--wezterm.on("save_session", function(window) session_manager.save_state(window) end)
--wezterm.on("load_session", function(window) session_manager.load_state(window) end)
--wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)


-- These are vars to put things in later (i dont use em all yet)
local config = {}
local keys = {}
local mouse_bindings = {}
local launch_menu = {}

-- This is for newer wezterm vertions to use the config builder 
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Default config settings
-- These are the default config settins needed to use Wezterm
-- Just add this and return config and that's all the basics you need

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Tokyo Night'
-- This is my chosen font, we will get into installing fonts on windows later
config.font = wezterm.font_with_fallback({
  {family ="Hack Nerd Font", scale = 1},
  {family ="JetBrainsMono Nerd Font", scale = 1}
  })

config.automatically_reload_config = true
config.window_background_opacity = 0.9
config.window_decorations = "TITLE|RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 5000
config.default_workspace = "main"

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.switch_to_last_active_tab_when_closing_tab = true

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.24,
  brightness = 0.5
}


--config.debug_key_events = true

--config.unix_domains = {
--  {
--    name = 'wsl',
--	serve_command = { 'wsl', 'wezterm-mux-server', '--daemonize' },
    -- Override the default path to match the default on the host win32
    -- filesystem.  This will allow the host to connect into the WSL
    -- container.
--    socket_path = '/mnt/c/Users/Aleksey Bevz/sock',
    -- NTFS permissions will always be "wrong", so skip that check
--    skip_permissions_check = true,
--  },
--}
--config.default_gui_startup_args = { 'connect', 'wsl' }

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
  -- Send C-a when pressing C-a twice
  { key = "a",          mods = "LEADER|CTRL", action = act.SendKey { key = "a", mods = "CTRL" } },
  { key = "c",          mods = "LEADER",      action = act.ActivateCopyMode },
  { key = "phys:Space", mods = "LEADER",      action = act.ActivateCommandPalette },

  -- Pane keybindings
  { key = "-",          mods = "LEADER",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "|",          mods = "LEADER|SHIFT",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "h",          mods = "LEADER",      action = act.ActivatePaneDirection("Left") },
  { key = "j",          mods = "LEADER",      action = act.ActivatePaneDirection("Down") },
  { key = "k",          mods = "LEADER",      action = act.ActivatePaneDirection("Up") },
  { key = "l",          mods = "LEADER",      action = act.ActivatePaneDirection("Right") },
  { key = "q",          mods = "LEADER",      action = act.CloseCurrentPane { confirm = true } },
  { key = "z",          mods = "LEADER",      action = act.TogglePaneZoomState },
  { key = "o",          mods = "LEADER",      action = act.RotatePanes "Clockwise" },
  -- We can make separate keybindings for resizing panes
  -- But Wezterm offers custom "mode" in the name of "KeyTable"
  { key = "r",          mods = "LEADER",      action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },

  -- Tab keybindings
  { key = "t",          mods = "LEADER",      action = act.SpawnTab("CurrentPaneDomain") },
  { key = "[",          mods = "LEADER",      action = act.ActivateTabRelative(-1) },
  { key = "]",          mods = "LEADER",      action = act.ActivateTabRelative(1) },
  { key = "n",          mods = "LEADER",      action = act.ShowTabNavigator },
  {
    key = "e",
    mods = "LEADER",
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Renaming Tab Title...:" },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end)
    }
  },
  -- Key table for moving tabs around
  { key = "m", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_tab", one_shot = false } },
  -- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
  { key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

  -- Lastly, workspace
  { key = "w", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },
  { key = "Z", mods = "LEADER", 	  action = wezterm.action_callback(function(window, pane)
    ssh.ssh_menu(window, pane)
  end)},
 -- ----------------------------------------------------------------
    -- Workspaces
    --
    -- These are roughly equivalent to tmux sessions.
    -- ----------------------------------------------------------------

    -- Attach to muxer
    -- {
        -- key = 'a',
        -- mods = 'LEADER',
        -- action = act.AttachDomain 'wsl',
    -- },

    -- -- Detach from muxer
    -- {
        -- key = 'd',
        -- mods = 'LEADER',
        -- action = act.DetachDomain { DomainName = 'wsl' },
    -- },

    -- -- Show list of workspaces
    -- {
        -- key = 's',
        -- mods = 'LEADER',
        -- action = act.ShowLauncherArgs { flags = 'WORKSPACES' },
    -- },
    -- -- Rename current session; analagous to command in tmux
    -- {
        -- key = '$',
        -- mods = 'LEADER|SHIFT',
        -- action = act.PromptInputLine {
            -- description = 'Enter new name for session',
            -- action = wezterm.action_callback(
                -- function(window, pane, line)
                    -- if line then
                        -- mux.rename_workspace(
                            -- window:mux_window():get_workspace(),
                            -- line
                        -- )
                    -- end
                -- end
            -- ),
        -- },
    -- },

    -- Session manager bindings
    -- {
        -- key = 'S',
        -- mods = 'LEADER|SHIFT',
        -- action = act({ EmitEvent = "save_session" }),
    -- },
    -- {
        -- key = 'L',
        -- mods = 'LEADER|SHIFT',
        -- action = act({ EmitEvent = "load_session" }),
    -- },
    -- {
        -- key = 'R',
        -- mods = 'LEADER|SHIFT',
        -- action = act({ EmitEvent = "restore_session" }),
    -- },
}

-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1)
  })
end

config.key_tables = {
  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize { "Left", 1 } },
    { key = "j",      action = act.AdjustPaneSize { "Down", 1 } },
    { key = "k",      action = act.AdjustPaneSize { "Up", 1 } },
    { key = "l",      action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
  move_tab = {
    { key = "h",      action = act.MoveTabRelative(-1) },
    { key = "j",      action = act.MoveTabRelative(-1) },
    { key = "k",      action = act.MoveTabRelative(1) },
    { key = "l",      action = act.MoveTabRelative(1) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  }
}

-- Tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
wezterm.on("update-status", function(window, pane)
  -- Workspace name
  local stat = window:active_workspace()
  local stat_color = "#f7768e"
  -- It's a little silly to have workspace name all the time
  -- Utilize this to display LDR or current key table name
  if window:active_key_table() then
    stat = window:active_key_table()
    stat_color = "#7dcfff"
  end
  if window:leader_is_active() then
    stat = "LDR"
    stat_color = "#bb9af7"
  end

  local basename = function(s)
    -- Nothing a little regex can't fix
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
  end

  -- Current working directory
  local cwd = pane:get_current_working_dir()
  if cwd then
    if type(cwd) == "userdata" then
      -- Wezterm introduced the URL object in 20240127-113634-bbcac864
      cwd = basename(cwd.file_path)
    else
      -- 20230712-072601-f4abf8fd or earlier version
      cwd = basename(cwd)
    end
  else
    cwd = ""
  end

  -- Current command
  local cmd = pane:get_foreground_process_name()
  -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
  cmd = cmd and basename(cmd) or ""

  -- Time
  local time = wezterm.strftime("%H:%M")

  -- Left status (left of the tab line)
  window:set_left_status(wezterm.format({
    { Foreground = { Color = stat_color } },
    { Text = "  " },
    { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
    { Text = " |" },
  }))

  -- Right status
  window:set_right_status(wezterm.format({
    -- Wezterm has a built-in nerd fonts
    -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
    { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
    { Text = " | " },
    { Foreground = { Color = "#e0af68" } },
    { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
    "ResetAttributes",
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
    { Text = "  " },
  }))
end)

-- IMPORTANT: Sets WSL2 UBUNTU-22.04 as the defualt when opening Wezterm
--config.default_domain = 'WSL:Ubuntu-24.04'

return config
