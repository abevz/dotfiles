local wezterm = require "wezterm" ---@class WezTerm
local act = wezterm.action ---@class WezTermAction

local M = {}

-- simple promt to create a workspace base on name, if exist go to it
function M.SwitchOrCreateWorkspace()
  return act.PromptInputLine {
    description = wezterm.format {
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      { Text = "Enter name for new workspace" },
    },
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:perform_action(act.SwitchToWorkspace { name = line }, pane)
      end
    end),
  }
end

function M.RenameWorkspace(workspaceName)
  return act.PromptInputLine {
    description = wezterm.format {
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      {
        Text = "Enter the new name for the workspace ("
          .. (workspaceName or "current")
          .. ")",
      },
    },
    action = wezterm.action_callback(function(window, pane, line)
      if line and line ~= "" then
        local target_workspace = workspaceName or wezterm.mux.get_active_workspace()

        -- Check if a specific workspace name is provided and if it exists
        if workspaceName then
          local workspace_exists = false
          for _, name in pairs(wezterm.mux.get_workspace_names()) do
            if name == workspaceName then
              workspace_exists = true
              break
            end
          end

          if not workspace_exists then
            wezterm.log_warn("Workspace '" .. workspaceName .. "' does not exist.")
            return
          end
        end

        -- Proceed to rename the workspace
        if target_workspace then
          wezterm.mux.rename_workspace(target_workspace, line)
        end
      end
    end),
  }
end

function M.SwitchWorkspaceTabs(config)
  config = config or {}
  -- Configuration with default values
  local sep = config.separator or " | "
  local workspaceLabel = config.workspaceLabel
    or wezterm.nerdfonts.md_dock_window .. " " .. "Workspace: "

  local tabLabel = config.tabLabel or wezterm.nerdfonts.md_tab .. " " .. "Tab: "
  local paneLabel = config.paneLabel
    or wezterm.nerdfonts.cod_split_horizontal .. " " .. "Pane: "

  return wezterm.action_callback(function(window, pane)
    local all_windows = wezterm.mux.all_windows()
    local choices = {}
    local workspaceMap = {}

    for _, win in ipairs(all_windows) do
      local workspace_name = win:get_workspace()
      if workspace_name then
        wezterm.log_info("Workspace: " .. workspace_name)
      end

      local tabs = win:tabs_with_info()
      for _, tab_info in ipairs(tabs) do
        local tab_id = tostring(tab_info.tab:tab_id())
        local tab_str = tabLabel .. tab_id

        -- Additional details from panes
        local pane_details = ""
        local isFirstPane = true
        for _, pane_info in ipairs(tab_info.tab:panes()) do
          local pane_title = pane_info:get_title() or ""

          if isFirstPane then
            pane_details = paneLabel .. pane_title
            isFirstPane = false
          else
            pane_details = pane_details .. sep .. paneLabel .. pane_title
          end
        end

        local label = (workspace_name and (workspaceLabel .. workspace_name) or "")
          .. sep
          .. tab_str
          .. sep
          .. pane_details

        workspaceMap[tab_id] = workspace_name
        table.insert(choices, {
          id = tab_id,
          label = label,
        })
      end
    end

    window:perform_action(
      act.InputSelector {
        title = "Choose Workspace/Tab",
        choices = choices,
        description = "Press the key corresponding to the Tab you want to switch to! Press '/' to start FuzzySearch",
        action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
          if id then
            local target_tab_id = tostring(id)
            local target_workspace_name = workspaceMap[target_tab_id]

            -- Switch to the workspace first
            if target_workspace_name then
              inner_window:perform_action(
                act.SwitchToWorkspace { name = target_workspace_name },
                inner_pane
              )
            end

            -- Then activate the tab
            local target_tab = wezterm.mux.get_tab(target_tab_id)
            if target_tab then
              target_tab:activate()
              wezterm.log_info("Switching to tab: " .. target_tab_id)
            end
          end
        end),
      },
      pane
    )
  end)
end

function M.SwitchPanes(config)
  config = config or {}
  -- Configuration with default values
  local sep = config.separator or " | "
  local workspaceLabel = config.workspaceLabel
    or wezterm.nerdfonts.md_dock_window .. " " .. "Workspace: "
  local tabLabel = config.tabLabel or wezterm.nerdfonts.md_tab .. " " .. "Tab: "
  local paneLabel = config.paneLabel
    or wezterm.nerdfonts.cod_split_horizontal .. " " .. "Pane: "

  return wezterm.action_callback(function(window, pane)
    local all_windows = wezterm.mux.all_windows()
    local choices = {}
    local paneMap = {}

    for _, win in ipairs(all_windows) do
      local workspace_name = win:get_workspace()
      if workspace_name then
        wezterm.log_info("Workspace: " .. workspace_name)
      end

      local tabs = win:tabs_with_info()

      for _, tab_info in ipairs(tabs) do
        local tab_id = tostring(tab_info.tab:tab_id())
        local workspace_str = workspace_name and (workspaceLabel .. workspace_name) or ""
        local tab_str = tabLabel .. tab_id

        for _, pane_info in ipairs(tab_info.tab:panes()) do
          local pane_title = pane_info:get_title() or ""
          local pane_id = tostring(pane_info:pane_id())

          -- Construct label for each pane
          local label = workspace_str .. sep .. tab_str .. sep .. paneLabel .. pane_title

          -- Insert choice for each pane
          table.insert(choices, {
            id = pane_id,
            label = label,
          })
          -- Update paneMap
          paneMap[pane_id] = workspace_name
          wezterm.log_info(
            "Mapping pane " .. pane_id .. " to workspace " .. (workspace_name or "nil")
          )
        end
      end
    end

    window:perform_action(
      act.InputSelector {
        choices = choices,
        alphabet = "123456789",
        description = "Press the key corresponding to the pane you want to switch to ! Press '/' to start FuzzySearch",
        action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
          if id then
            local target_pane_id = tostring(id)
            wezterm.log_info("Target Pane ID: " .. target_pane_id)
            local target_workspace_name = paneMap[target_pane_id]
            wezterm.log_info("Target Workspace: " .. target_workspace_name)

            -- Switch to the workspace first
            if target_workspace_name then
              -- NOTES: this is the only way to achieve workspace change
              inner_window:perform_action(
                act.SwitchToWorkspace { name = target_workspace_name },
                inner_pane
              )
            end
            -- Activate the pane
            local target_pane = wezterm.mux.get_pane(target_pane_id)
            wezterm.log_info(
              "Target Pane found by the mux: " .. wezterm.to_string(target_pane)
            )
            if target_pane then
              target_pane:activate()
              wezterm.log_info("Switching to pane: " .. target_pane_id)
            end
          end
        end),
      },
      pane
    )
  end)
end

return M
