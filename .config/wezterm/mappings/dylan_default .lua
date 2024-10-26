-- local fun = require "utils.fun" ---@class Fun
local dylan = require "utils.dylan" ---@class Dylan
local inspect = require "plugins.inspect" ---@class Inspect
local ssh = require "plugins.ssh_menu" ---@class SSH
local marks = require "plugins.marks" ---@class Marks
local workspace_manager = require "plugins.workspace_manager" ---@class WorkspaceManager
local personnal_notes = require "plugins.personnal_notes" ---@class PersonnalNotes
local vim_keymap = require "plugins.vim_keymap" ---@class VimKeymap
local wez = require "wezterm"
local workspace_switcher =
  -- zoxide + workspace switcher
  wez.plugin.require "https://github.com/MLFlexer/smart_workspace_switcher.wezterm"
local session_manager = require "wezterm-session-manager\\session-manager"
---@class Config
local Config = {}

local act = wez.action

-- this is called by the mux server when it starts up.
-- It makes a window split top/bottom

Config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

local keys = {
  ["<C-Tab>"] = act.ActivateTabRelative(1),
  ["<C-S-Tab>"] = act.ActivateTabRelative(-1),
  ["<C-S-c>"] = act.CopyTo "Clipboard",
  ["<C-S-v>"] = act.PasteFrom "Clipboard", --TODO: maybe adapt this a bit
  -- ["<C-c>"] = act.CopyTo "Clipboard",
  ["<C-v>"] = act.PasteFrom "Clipboard",
  -- ["<C-S-f>"] = act.Search "CurrentSelectionOrEmptyString",
  ["<C-S-k>"] = act.ClearScrollback "ScrollbackOnly",
  ["<C-S-l>"] = act.ShowDebugOverlay,
  ["<C-S-n>"] = act.SpawnWindow,
  ["<C-S-p>"] = act.ActivateCommandPalette,
  ["<C-S-r>"] = act.ReloadConfiguration,
  ["<C-S-t>"] = act.SpawnTab "CurrentPaneDomain",
  ["<C-S-u>"] = act.CharSelect {
    copy_on_select = true,
    copy_to = "ClipboardAndPrimarySelection",
  },
  ["<C-S-w>"] = act.CloseCurrentTab { confirm = true },
  ["<C-S-z>"] = act.TogglePaneZoomState,
  ["<PageUp>"] = act.ScrollByPage(-1),
  ["<PageDown>"] = act.ScrollByPage(1),
  ["<C-S-Insert>"] = act.PasteFrom "PrimarySelection",
  -- ["<C-Insert>"] = act.CopyTo "PrimarySelection",
  -- ["<C-S-Space>"] = act.QuickSelect,

  ---quick split and nav
  ['<C-S-">'] = act.SplitHorizontal { domain = "CurrentPaneDomain" },
  ["<C-S-%>"] = act.SplitVertical { domain = "CurrentPaneDomain" },
  -- ["<C-M-h>"] = act.ActivatePaneDirection "Left",
  -- ["<C-M-j>"] = act.ActivatePaneDirection "Down",
  -- ["<C-M-k>"] = act.ActivatePaneDirection "Up",
  -- ["<C-M-l>"] = act.ActivatePaneDirection "Right",

  ---key tables
  ["<leader>w"] = act.ActivateKeyTable { name = "window_mode", one_shot = false },
  ["<leader>P"] = act.ActivateKeyTable { name = "font_mode", one_shot = false },
  ["<C-S-x>"] = act.ActivateCopyMode,
  ["<C-S-f>"] = act.Search "CurrentSelectionOrEmptyString",
  --
  -- ["<leader>-C-a"] = act { SendString = "\x01" },

  ["<leader>-"] = act { SplitVertical = { domain = "CurrentPaneDomain" } },
  -- ["<leader>\\"] = act { SplitHorizontal = { domain = "CurrentPaneDomain" } },
  ["<leader>s"] = act { SplitVertical = { domain = "CurrentPaneDomain" } },
  ["<leader>v"] = act { SplitHorizontal = { domain = "CurrentPaneDomain" } },
  ["<leader>o"] = act.TogglePaneZoomState,
  ["<leader>z"] = act.TogglePaneZoomState,
  ["<leader>c"] = act { SpawnTab = "CurrentPaneDomain" },
  ["<leader>h"] = act { ActivatePaneDirection = "Left" },
  ["<leader>j"] = act { ActivatePaneDirection = "Down" },
  ["<leader>k"] = act { ActivatePaneDirection = "Up" },
  ["<leader>l"] = act { ActivatePaneDirection = "Right" },
  ["<leader>H"] = act { AdjustPaneSize = { "Left", 5 } },
  ["<leader>J"] = act { AdjustPaneSize = { "Down", 5 } },
  ["<leader>K"] = act { AdjustPaneSize = { "Up", 5 } },
  ["<leader>L"] = act { AdjustPaneSize = { "Right", 5 } },
  ["<leader>1"] = act { ActivateTab = 0 },
  ["<leader>2"] = act { ActivateTab = 1 },
  ["<leader>3"] = act { ActivateTab = 2 },
  ["<leader>4"] = act { ActivateTab = 3 },
  ["<leader>5"] = act { ActivateTab = 4 },
  ["<leader>6"] = act { ActivateTab = 5 },
  ["<leader>7"] = act { ActivateTab = 6 },
  ["<leader>8"] = act { ActivateTab = 7 },
  ["<leader>9"] = act { ActivateTab = 8 },
  ["<leader>x"] = act { CloseCurrentPane = { confirm = true } },
  ["<leader>F"] = workspace_switcher.switch_workspace(),
  ["<leader>f"] = workspace_manager.SwitchPanes(),
  ["<leader>r"] = workspace_manager.RenameWorkspace(),
  ["<leader>S"] = wez.action_callback(function(window)
    session_manager.save_state(window)
  end),
  ["<leader>O"] = wez.action_callback(function(window)
    session_manager.load_state(window)
  end),
  ["<leader>R"] = wez.action_callback(function(window)
    session_manager.restore_state(window)
  end),
  -- ["<leader>N"] = dylan.RenameWorkspace "SuperTest", -- NOTE: test work just fine
  ["<leader>d"] = wez.action_callback(function(window)
    session_manager.delete_saved_session(window)
  end),
  ["<leader>B"] = wez.action_callback(function(window)
    session_manager.resurrect_all_sessions(window)
  end),
  ["<leader>N"] = personnal_notes.SwitchToNotesWorkspace(),
  ["<leader>M"] = wez.action_callback(function(window)
    marks.WriteMarkToDisk(window)
  end),
  ["<leader>m"] = wez.action_callback(function(window)
    marks.AccessMarkFromDisk(window)
  end),
  ["<leader>Z"] = wez.action_callback(function(window, pane)
    ssh.ssh_menu(window, pane)
  end),
  -- NOTE: Windows elevation is problematic it need a new window to be spawned
  -- Windows terminal cant do it either
  -- Maybe try https://github.com/wez/wezterm/issues/167
  -- ["<4eader>E"] = act.SpawnCommandInNewTab {
  --   args = { "-Verb Runas" },
  -- },
  ["<C-1>"] = act.SendKey {
    key = "1",
    mods = "CTRL",
  },
  ["<C-2>"] = act.SendKey {
    key = "2",
    mods = "CTRL",
  },
  ["<C-3>"] = act.SendKey {
    key = "3",
    mods = "CTRL",
  },
  ["<C-4>"] = act.SendKey {
    key = "4",
    mods = "CTRL",
  },
  ["<C-5>"] = act.SendKey {
    key = "5",
    mods = "CTRL",
  },
  ["<C-6>"] = act.SendKey {
    key = "6",
    mods = "CTRL",
  },
  ["<C-7>"] = act.SendKey {
    key = "7",
    mods = "CTRL",
  },
  ["<C-m>"] = act.SendKey {
    key = "m",
    mods = "CTRL",
  },
}

Config.keys = {}
for lhs, rhs in pairs(keys) do
  vim_keymap.map(lhs, rhs, Config.keys)
end

return Config
