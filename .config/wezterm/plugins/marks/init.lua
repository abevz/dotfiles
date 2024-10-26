local wezterm = require "wezterm"

---@class Config
local M = {}

--- provided by wezterm-session-manager/session-manager.lua
--- Saves data to a JSON file.
--- @param data table: The workspace data to be saved.
--- @param file_path string: The file path where the JSON file will be saved.
--- @return boolean: true if saving was successful, false otherwise.
local function save_to_json_file(data, file_path)
  if not data then
    wezterm.log_info "No workspace data to log."
    return false
  end

  local file = io.open(file_path, "w")
  if file then
    file:write(wezterm.json_encode(data))
    file:close()
    return true
  else
    return false
  end
end

--- Writes the current workspace, tab, and pane information to disk.
--- This function captures the current state of the WezTerm workspace, including
--- the active workspace name, tab ID, and pane ID, and saves this information
--- in a JSON file at the specified or default path.
--- @param window window: The active window object from which workspace data is extracted.
--- @param mark_file_path string: (optional) The file path where the mark data will be saved.
--- Defaults to `config_dir/.marks`.
function M.WriteMarkToDisk(window, mark_file_path)
  -- Use the provided path or default to config_dir/.marks
  mark_file_path = mark_file_path or wezterm.config_dir .. "/.marks"

  local active_tab = window:active_tab()
  local active_workspace_name = window:active_workspace()
  local active_pane = active_tab:active_pane()

  local mark_data = {
    workspace_name = active_workspace_name,
    tab_id = tostring(active_tab:tab_id()),
    pane_id = tostring(active_pane:pane_id()),
  }

  -- Save mark data to file and show toast notification if successful
  if save_to_json_file(mark_data, mark_file_path) then
    window:toast_notification(
      "WezTerm Marks",
      "Workspace Marks saved successfully",
      nil,
      2000
    )
  else
    wezterm.log_error("Failed to save mark data to file: " .. mark_file_path)
  end
end

--- Accesses and activates the workspace and pane from saved data on disk.
--- This function reads the saved workspace and pane information from a JSON file
--- and activates the specified workspace and pane in the given window.
--- @param window window: The active window object in which the workspace and pane will be activated.
--- @param mark_file_path string: (optional) The file path from where the mark data will be read.
--- Defaults to `config_dir/.marks`.
function M.AccessMarkFromDisk(window, mark_file_path)
  -- Use the provided path or default to config_dir/.marks
  mark_file_path = mark_file_path or wezterm.config_dir .. "/.marks"

  local file = io.open(mark_file_path, "r")
  if not file then
    wezterm.log_error("Failed to open mark file for reading: " .. mark_file_path)
    return
  end

  local json_data = file:read "*a"
  file:close()

  local mark_data = wezterm.json_parse(json_data)
  if not mark_data then
    wezterm.log_error "Failed to parse mark data from file"
    return
  end

  -- Switch to the workspace first
  if mark_data.workspace_name then
    window:perform_action(
      wezterm.action.SwitchToWorkspace { name = mark_data.workspace_name },
      window:active_pane()
    )
  end

  -- BUG: here return nil ? but prog work still
  -- Then find and activate the target pane
  local panes = wezterm.mux.get_all_panes()
  local target_pane = nil
  for _, pane in ipairs(panes) do
    if tostring(pane:pane_id()) == mark_data.pane_id then
      target_pane = pane
      break
    end
  end

  if target_pane then
    target_pane:activate()
    wezterm.log_info("Switching to pane: " .. mark_data.pane_id)
  else
    wezterm.log_error("Could not find target pane with ID: " .. mark_data.pane_id)
  end
end

return M
