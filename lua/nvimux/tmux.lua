--- Tmux functionality for nvimux
local config = require("nvimux.config")
local log = require("nvimux.log")

local M = {}

local function all_trim(s)
	return s:match("^%s*(.-)%s*$")
end

--- Checks if the configured tmux command is executable
-- using neovims function
-- @return bool true if executable, false else
M.is_executable = function()
	local command = config.get("tmux_command")
	return vim.fn.executable(command) == 1
end

--- Utility function to add something to a list, which is
-- either a table which will be flattened or something else
-- which will be appended
-- @param list table
-- @return table list
local function add_to_list(list, add_list)
	if add_list ~= nil then
		for _, v in ipairs(add_list) do
			if type(v) == "table" then
				add_to_list(list, v)
			else
				table.insert(list, tostring(v))
			end
		end
	end
	return list
end

M.exe = function(cmd)
	local command = { config.get("tmux_command") }

	if type(cmd) == "string" then
		cmd = { cmd }
	end

	command = add_to_list(command, cmd)
	log.log(command)
	if vim.env.TMUX == nil then
		vim.message("Not in a tmux session (TMUX environment variable not found)", vim.log.levels.ERROR)
	else
		local result = vim.system(command):wait()
		log.log(result)
		return all_trim(result.stdout)
	end
	return ""
end

M.send_keys = function(runner, keys)
	M.exe({ "send-keys", "-t", runner, keys })
end

M.get_property = function(name, runner)
	local command = { "display" }
	if runner ~= nil then
		table.insert(command, "-t")
		table.insert(command, runner)
	end
	table.insert(command, "-p")
	table.insert(command, name)
	return M.exe(command)
end

return M
