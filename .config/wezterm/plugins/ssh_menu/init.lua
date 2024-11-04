local wezterm = require "wezterm"
local act = wezterm.action
local M = {}
local SSH_AUTH_SOCK = os.getenv 'SSH_AUTH_SOCK'


function shell(cmd)
    local output = "null"
    local f = io.popen(cmd)
    if f ~= nil then
        output = f:read("*all")
        f:close()
    end
    return output
end


--TODO : generate entry for SSH keys directly In command palet too ?
--TODO: Maybe offer parsing of ~/.ssh/config too ?
--
-- Function to read SSH hosts from the config
local function get_known_hosts_path()
  -- if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    -- Windows path
    -- return wezterm.home_dir .. "\\.ssh\\known_hosts"
  -- else
    -- Default to Unix-like path for macOS and Linux
    return "~/.ssh/known_hosts"
  --end
end

-- Function to read SSH hosts from the known hosts file
local function read_ssh_hosts()
  local ssh_hosts = {}
  wezterm.log_info("Start forming list of servers")
  wezterm.log_info('shell: ' .. shell("echo $SSH_AUTH_SOCK"))
--  wezterm.log_info("Default sock" .. os.getenv("SSH_AUTH_SOCK"))
	if ssh_hosts == nil then
		ssh_hosts = {}
	end

	for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
    if host ~= ".host" then
    table.insert(ssh_hosts,host
		--       {
		-- 	name = host,
		-- 	remote_address = config.hostname .. ":" .. config.port,
		-- 	username = config.user,
		-- 	multiplexing = "None",
		-- 	assume_shell = "Posix",
		-- }
      )
    
   wezterm.log_info("Finded hosts:" .. host)

    end
  end
   
--  local known_hosts_file = get_known_hosts_path()
--  wezterm.log_info("Reading known hosts from: " .. known_hosts_file)

  -- local f = io.open(known_hosts_file, "r")
  -- if f then
  --   for line in f:lines() do
  --     -- Assuming each line in the file is a hostname
  --     local host = line:match "%S+" -- Extracts the first word in each line
  --     if host then
  --       table.insert(ssh_hosts, host)
  --       wezterm.log_info("Found host: " .. host)
  --     end
  --   end
  --   f:close()
  -- else
  --   wezterm.log_error "Unable to open known hosts file"
  -- end
  return ssh_hosts
end

-- Function to show the SSH menu
function M.ssh_menu(window, pane)
  local ssh_hosts = read_ssh_hosts()
  local choices = {}
  for _, host in ipairs(ssh_hosts) do
    wezterm.log_info( _ .. host)
    table.insert(choices, { label = "SSH to " .. host })
  end

  window:perform_action(
    act.InputSelector {
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id and not label then
          wezterm.log_info "SSH connection cancelled"
        else
          local host = label:gsub("SSH to ", "")
          -- Removing brackets and splitting host and port
          local clean_host, port =
            host:gsub("%[", ""):gsub("%]", ""):match "([^:]+):?(%d*)"
          local ssh_command = { "ssh", clean_host }
          if port ~= "" then
            table.insert(ssh_command, "-p")
            table.insert(ssh_command, port)
          end
          wezterm.log_info(
            "Attempting SSH connection to: "
              .. clean_host
              .. (port ~= "" and (":" .. port) or "")
          )
          window:perform_action(
            wezterm.action.SpawnCommandInNewTab {
              args = ssh_command,
            },
            pane
          )
        end
      end),
      title = "Select SSH Host",
      choices = choices,
      alphabet = "123456789", -- TODO: find a way to show key before entry in the menu
      description = wezterm.nerdfonts.md_ssh
        .. " --> Select the number key the host for SSH connection ! Press '/' to start FuzzySearch <--",
    },
    pane
  )
end

return M
