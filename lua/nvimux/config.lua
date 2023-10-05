local log = require("nvimux.log")
local M = {}

---@type user_options
M.default_opts = {
	-- the height/width of the pane if it has to be created
	height = "20%",
	-- the orientation, either `h`orizontal or `v`ertical
	orientation = "v",
	-- Use a pane/window near the current one, if existing
	use_nearest = true,
	-- Reset equences based on the mode of the tmux pane
	reset_mode_sequence = {
		-- copy-mode could be left with `q`
		["copy-mode"] = "q",
	},
	-- The string to ask the user for a command to enter
	prompt_string = "Command? ",
  -- clear command line before sending command
  clear_commandline = true,
	-- Run in `pane` or `window`
	runner_type = "pane",
	-- Specify a specific pane/window name
	runner_name = "",
	-- Tmux command or full path to be used
	tmux_command = "tmux",
	-- additional arguments for the pane if created, as a list/table
	open_extra_args = {},
	-- Expand commands, entered into the prompt
	expand_command = false,
	-- Close the pane on exit
	close_on_exit = false,
	-- Provide shell command completion for prompt
	command_shell = true,
	-- Find a runner by a specific query, see tmux for possible filters
	runner_query = {},
	-- Key combinations used
	keys = {
		-- for clearing the current line
    clear_commandline = "C-u",
		-- for clearing the screen
		clear_screen = "C-l",
		-- for scrolling up in copy-mode
		scroll_up = "C-u",
		-- for scrolling down in copy-mode
		scroll_down = "C-d",
		-- for resetting the commandline (delete current line)
		reset_cmdline = "C-u",
		-- to interrupt runninng command
		interrupt = "C-c",
		-- to confirm command
		confirm_command = "Enter",
	},
}

-- Stores the global user-set options for the plugin.
M.user_opts = nil

-- Setup the global user options for all files.
---@param user_opts user_options|nil The user-defined options to be merged with default_opts.
M.setup = function(user_opts)
	if user_opts == nil then
		user_opts = {}
	end
	M.user_opts = vim.tbl_deep_extend("keep", user_opts, M.default_opts)
	log.log(M.user_opts)
end

-- Get a configuration parameter
---@param config_value_name string The name of the option to be returned
M.get = function(config_value_name)
  if string.find(config_value_name, '[.]') then
    local opt = M.user_opts
    for i in string.gmatch(config_value_name, "[^.]+") do
      opt = opt[i]
    end
    return opt
  end
	return M.user_opts[config_value_name]
end

-- Set/Update a configuration parameter
---@param config_value_name string The name of the option to be set
---@param value string value to be set
M.set = function(config_value_name, value)
	 M.user_opts[config_value_name] = value
end

-- Get a key combination parameter
---@param config_value_name string The name of the option to be returned
M.get_keys = function(config_value_name)
	return M.user_opts.keys[config_value_name]
end

return M
