--- The entry point for nvimux, the lua terminal interaction for neovim
local config = require("nvimux.config")
local utils = require("nvimux.utils")
local log = require("nvimux.log")

local M = {
	last_command = {},
	history_buffer = nil,
}

---Initial setup is required
M.setup = function(user_opts)
	config.setup(user_opts)
	utils.check()
	M.setup_commands()
end

---Ask user for rest of command, then execute it
---@param prefix string command prefix
M.prompt_command = function(prefix)
	local completion = ""
	if config.get("command_shell") then
		completion = "shellcmd"
	end
	local prompt = config.get("prompt_string")
	prefix = prefix or ""

	local opts = {
		prompt = prompt .. prefix,
		completion = completion,
		default = command,
	}

	vim.ui.input(opts, function(command)
		if command ~= nil then
			M.run(prefix .. command)
		end
	end)
end

---Run a command in a tmux pane
---@param command string Command/string to send to tmux pane
---@param autoreturn boolean true if return should be send after the command (default), false otherwise
M.run = function(command, autoreturn)
	if not utils.runner_exists() then
		utils.open()
	end
	autoreturn = autoreturn or true
	table.insert(M.last_command, command)
	utils.reset_runner_mode()
	utils.send_text(utils.expand_command(command))
	if autoreturn then
		utils.send_keys(config.get_keys("confirm_command"))
	end
end

---Rerun the last run command
M.run_last = function()
	if #M.last_command > 0 then
		M.run(M.last_command[#M.last_command])
	end
end


---Clear the history of the pane
M.set_runner_name = function(name)
	config.set('runner_name', name)
end

---Clear the history of the pane
M.clear_history = function()
	utils.clear_history()
end

---Clear the terminal in the pane
M.clear_terminal_screen = function()
	utils.send_keys(config.get_keys("clear_screen"))
end

---Interrupt the runners execution
M.interrupt_runner = function()
	utils.send_keys(config.get_keys("interrupt"))
end

---Switch runner to copy-mode
M.inspect_runner = function()
	local selected = utils.select()
	utils.copy_mode()
	return selected
end

---Switch runner to copy-mode and scroll up
M.inspect_scroll_up = function()
	if M.inspect_runner() then
		utils.last()
		utils.send_keys(config.get_keys("scroll_up"))
	end
end

---Switch runner to copy-mode and scroll down
M.inspect_scroll_down = function()
	if M.inspect_runner() then
		utils.last()
		utils.send_keys(config.get_keys("scroll_down"))
	end
end

---Puts the runner in zoom mode
M.zoom_runner = function()
	utils.zoom()
end

---Closes the runner
M.close_runner = function()
	utils.close()
end

---Makes a pane runner a window and vice versa
M.toggle = function()
	utils.toggle()
end

M.load_history = function(lines)
	local history = utils.get_history(lines)
	if M.history_buffer == nil then
		vim.api.nvim_command("botright vnew tmux-buffer")
		M.history_buffer = vim.api.nvim_get_current_buf()
		vim.bo[M.history_buffer].buftype = "nofile"
		vim.bo[M.history_buffer].bufhidden = "hide"
		vim.bo[M.history_buffer].swapfile = false
	elseif vim.fn.bufwinnr(M.history_buffer) == -1 then
		vim.api.nvim_command("botright vnew tmux-buffer")
	end
	vim.api.nvim_buf_set_lines(M.history_buffer, 0, -1, true, utils.prepare_text(history))
end

M.load_history_qf = function(lines, efm)
	local history = utils.get_history(lines)
	vim.fn.setqflist({}, " ", {
		title = "Tmux lines",
		lines = utils.prepare_text(history),
		efm = efm or vim.o.efm,
	})
end

M.send_keys = function(keys)
	utils.send_keys(keys)
end

M.send_text = function(text)
	utils.send_text(text)
end

M.open = function()
	utils.open()
end

M.CMDS = {
	{
		name = "NvimuxRunCommand",
		opts = { desc = "nvimux: run command", nargs = "*", complete = "shellcmd" },
		description = [[
    Run a shell command in an extra pane. Just run :NvimuxRunCommand <your_command>.
    ]],
		example = {[[
    "Run the current file with rspec, and keybinding
    vim.keymap.set("n", "<leader>vl", require("nvimux").run("clear; rspec " . bufname("%")), {})
    ]],
    [[
    "From the commandline
    :NvimuxRunCommand clear; rspec %
    ]],
    },
		command = function(c)
			M.run(c.args, true)
		end,
		api = "run(command, autoreturn)",
	},
	{
		name = "NvimuxSendText",
		opts = { desc = "nvimux: send text to the tmux pane", bar = true, nargs = "*" },
		description = [[
    Sends text, as it is to the runner pane if there is one opened.
    Interacts with any program or shell waiting for input.
    ]],
		example = [[
    " Send the content of the " register to the pane
    local get_reg = function()
      return vim.api.nvim_exec(\[\[echo getreg('\]\]..char..\[\[')\]\], true):gsub("[\n\r]", "^J")
    end
    vim.keymap.set("n", "<leader>P", require("nvimux").send_keys(get_reg("\"")), {})
    ]],
		command = function(c)
			M.send_text(c.args)
		end,
		api = "send_text(your_string)",
	},
	{
		name = "NvimuxSendKeys",
		opts = { desc = "nvimux: sends a key or key combination", bar = true, nargs = "*" },
		description = [[
    Sends key or keycombination (such ash C-u for Ctrl+u) to the runner pane if there is one opened.
    Interacts with any program or shell waiting for input.
    ]],
		command = function(c)
			M.send_keys(c.args)
		end,
		api = "send_keys(key)",
	},
	{
		name = "NvimuxRunLastCommand",
		opts = { desc = "nvimux: rerun last command", bar = true },
		description = [[
    Reruns the last command run with either |NvimuxRunCommand| or |NvimuxPromptCommand|
    ]],
		command = function()
			M.run_last()
		end,
		api = "run_last()",
	},
	{
		name = "NvimuxOpenRunner",
		opts = { desc = "nvimux: open runner", bar = true },
		command = function()
			utils.open()
		end,
		api = "open()",
	},
	{
		name = "NvimuxCloseRunner",
		opts = { desc = "nvimux: close runner", bar = true },
		description = [[
    Closes the open runner, if there is one.
    ]],
		command = function()
			M.close_runner()
		end,
		api = "close_runner()",
	},
	{
		name = "NvimuxZoomRunner",
		opts = { desc = "nvimux: zoom runner", bar = true },
		description = [[
    Zooms the runner, like the "<bindkey> z", which you can then use to unzoom.
    ]],
		command = function()
			M.zoom_runner()
		end,
		api = "zoom_runner()",
	},
	{
		name = "NvimuxInspectRunner",
		opts = { desc = "nvimux: inspect runner", bar = true },
		description = [[
    Puts the runnter into inspect/copy-mode, to scroll around
    ]],
		command = function()
			M.inspect_runner()
		end,
		api = "inspect_runner()",
	},
	{
		name = "NvimuxScrollUpInspect",
		opts = { desc = "nvimux: scroll runner up", bar = true },
		description = [[
    Puts the runnter into inspect/copy-mode if needed and scroll up.
    ]],
		command = function()
			M.inspect_scroll_up()
		end,
		api = "inspect_scroll_up()",
	},
	{
		name = "NvimuxScrollDownInspect",
		opts = { desc = "nvimux: scroll runner down", bar = true },
		description = [[
    Puts the runnter into inspect/copy-mode if needed and scroll down.
    ]],
		command = function()
			M.inspect_scroll_down()
		end,
		api = "inspect_scroll_down()",
	},
	{
		name = "NvimuxInterruptRunner",
		opts = { desc = "nvimux: interrupt running", bar = true },
		description = [[
    Sends Ctrl-c, to the running process in the open pane.
    ]],
		command = function()
			M.interrupt_runner()
		end,
		api = "interrupt_runner()",
	},
	{
		name = "NvimuxPromptCommand",
		opts = { desc = "nvimux: interrupt running", nargs = "*" },
		description = [[
    Opens a prompt to be filled, allows to add some prefix command.
    ]],
		command = function(c)
			M.prompt_command(c.args)
		end,
		api = "prompt_command(<prefix>)",
	},
	{
		name = "NvimuxClearTerminalScreen",
		opts = { desc = "nvimux: interrupt running", bar = true },
		description = [[
    Clears the screen in the pane.
    ]],
		command = function()
			M.clear_terminal_screen()
		end,
		api = "clear_terminal_screen()",
	},
	{
		name = "NvimuxClearRunnerHistory",
		opts = { desc = "nvimux: interrupt running", bar = true },
		description = [[
    Clears the tmux history in the pane.
    ]],
		command = function()
			M.clear_history()
		end,
		api = "clear_history()",
	},
	{
		name = "NvimuxTogglePane",
		opts = { desc = "nvimux: interrupt running", bar = true },
		description = [[
    Makes a pane a window and vice versa, will not change the settings.
    ]],
		command = function()
			M.toggle()
		end,
		api = "toggle()",
	},
	{
		name = "NvimuxLog",
		opts = { desc = "nvimux: print log", bar = true },
		description = [[
    Print the stored log entries of nvimux.
    ]],
		command = function()
			log.printlog()
		end,
	},
	{
		name = "NvimuxLoadPane",
		opts = { desc = "nvimux: loads pane into a buffer", bar = true, nargs = "?" },
		description = [[
    This will load all the history of a pane up to the numer of lines, or all if not specified, into a buffer.
    ]],
		command = function(c)
			M.load_history(c.args)
		end,
		api = "toggle()",
	},
	{
		name = "NvimuxQuickFix",
		opts = { desc = "nvimux: loads pane into the quickfix buffer", bar = true, nargs = "*" },
		description = [[
    This will load all the history of a pane up to the numer of lines, or all if not specified into the quickfix list
    The first argument is the number of lines, the second one is a specific errorformat, else the default will be used.
    ]],
		command = function(c)
			M.load_history_qf(c.fargs)
		end,
		api = "toggle()",
	},
}

M.setup_commands = function()
	for _, cmd in ipairs(M.CMDS) do
		local opts = vim.tbl_extend("force", cmd.opts, { force = true })
		vim.api.nvim_create_user_command(cmd.name, cmd.command, opts)
	end
end

return M
