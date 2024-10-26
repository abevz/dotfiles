local wezterm = require "wezterm"
local M = {}
-- wez.to_string(tab) print only memory address and not all the item of the table sadly
--
--TODO : manage depth
--for example with users_vars[]
--
-- NOTE: maybe im stupid wezterm:log_info seems to read the object entirely

-- They are not all tested so modifications might be needed
-- All the available wezterm object
M.wezObjects = {
  ["Color:"] = {
    properties = {
      "adjust_hue_fixed",
      "adjust_hue_fixed_ryb",
      "complement",
      "complement_ryb",
      "contrast_ratio",
      "darken",
      "darken_fixed",
      "delta_e",
      "desaturate",
      "desaturate_fixed",
      "hsla",
      "laba",
      "lighten",
      "lighten_fixed",
      "linear_rgba",
      "saturate",
      "saturate_fixed",
      "square",
      "srgb_u8",
      "triad",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/Color.html",
  },
  ["LocalProcessInfo:"] = {
    properties = {
      "pid",
      "ppid",
      "name",
      "status",
      "argv",
      "executable",
      "cwd",
      "children",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/LocalProcessInfo.html",
  },
  ["MuxDomain:"] = {
    properties = {
      "attach",
      "detach",
      "domain_id",
      "has_any_panes",
      "is_spawnable",
      "label",
      "name",
      "state",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/MuxDomain.html",
  },
  ["MuxWindow"] = {
    properties = {
      "active_pane",
      "active_tab",
      "get_title",
      "get_workspace",
      "gui_window",
      "set_title",
      "set_workspace",
      "spawn_tab",
      "tabs",
      "tabs_with_info",
      "window_id",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/MuxWindow.html",
  },
  ["MuxTab:"] = {
    properties = {
      "activate",
      "active_pane",
      "get_pane_direction",
      "get_size",
      "get_title",
      "panes",
      "panes_with_info",
      "rotate_clockwise",
      "rotate_counter_clockwise",
      "set_title",
      "set_zoomed",
      "tab_id",
      "window",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/MuxTab.html",
  },
  ["PaneInformation:"] = {
    properties = {
      "pane_id",
      "pane_index",
      "is_active",
      "is_zoomed",
      "left",
      "top",
      "width",
      "height",
      "pixel_width",
      "pixel_height",
      "title",
      "user_vars",
      "foreground_process_name",
      "current_working_dir",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/PaneInformation.html",
  },
  ["TabInformation:"] = {
    properties = {
      "tab_id",
      "tab_index",
      "is_active",
      "active_pane",
      "window_id",
      "window_title",
      "tab_title",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/TabInformation.html",
  },
  ["Time:"] = {
    properties = { "format", "format_utc", "sun_times" },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/Time.html",
  },
  ["Pane:"] = {
    properties = {
      "activate",
      "get_current_working_dir",
      "get_cursor_position",
      "get_dimensions",
      "get_domain_name",
      "get_foreground_process_info",
      "get_foreground_process_name",
      "get_lines_as_text",
      "get_logical_lines_as_text",
      "get_metadata",
      "get_semantic_zone_at",
      "get_semantic_zones",
      "get_text_from_region",
      "get_text_from_semantic_zone",
      "get_title",
      "get_tty_name",
      "get_user_vars",
      "has_unseen_output",
      "inject_output",
      "is_alt_screen_active",
      "move_to_new_tab",
      "move_to_new_window",
      "mux_pane",
      "pane_id",
      "paste",
      "send_paste",
      "send_text",
      "split",
      "tab",
      "window",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/Pane.html",
  },
  ["Window:"] = {
    properties = {
      "active_key_table",
      "active_pane",
      "active_tab",
      "active_workspace",
      "composition_status",
      "copy_to_clipboard",
      "current_event",
      "effective_config",
      "focus",
      "get_appearance",
      "get_config_overrides",
      "get_dimensions",
      "get_selection_escapes_for_pane",
      "get_selection_text_for_pane",
      "is_focused",
      "keyboard_modifiers",
      "leader_is_active",
      "maximize",
      "mux_window",
      "perform_action",
      "restore",
      "set_config_overrides",
      "set_inner_size",
      "set_left_status",
      "set_position",
      "set_right_status",
      "toast_notification",
      "toggle_fullscreen",
      "window_id",
    },
    docsurl = "https://wezfurlong.org/wezterm/config/lua/Window.html",
  },
}

function M.inspectWezObject(object) -- BUG : case i W O
  local objectTypeString = wezterm.to_string(object)
  local result = {}

  for objType, objDef in pairs(M.wezObjects) do
    if objectTypeString:find(objType) then
      table.insert(
        result,
        objType .. " Information (Documentation: " .. objDef.docsurl .. "):"
      )
      for _, prop in ipairs(objDef.properties) do
        local value = object[prop]
        if value ~= nil then
          if type(value) == "function" then
            value = value(object)
          end
          if type(value) == "table" then
            table.insert(result, "  " .. prop .. " = " .. wezterm.to_string(value))
          else
            table.insert(result, "  " .. prop .. " = " .. tostring(value))
          end
        else
          table.insert(result, "  " .. prop .. " = nil")
        end
      end
      return table.concat(result, "\n")
    end
  end

  return "<Unknown Object>: No inspection info available"
end

return M
