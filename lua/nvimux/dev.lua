-- Print some stuff, because I am lazy
local main = require("nvimux")
local utils = require("nvimux.utils")
local M = {}

local up = table.unpack or unpack

local default_config = {
	"  {",
	"    -- the height/width of the pane if it has to be created",
	"    height = '20%',",
	"    -- the orientation, either `h`orizontal or `v`ertical",
	'    orientation = "v",',
	"    -- Use a pane/window near the current one, if existing",
	"    use_nearest = true,",
	"    -- Reset equences based on the mode of the tmux pane",
	"    reset_mode_sequence = {",
	"      -- copy-mode could be left with `q`",
	'      ["copy-mode"] = "q",',
	"    },",
	"    -- The string to ask the user for a command to enter",
	'    prompt_string = "Command? ",',
	"    -- Run in `pane` or `window`",
	'    runner_type = "pane",',
	"    -- Specify a specific pane/window name",
	'    runner_name = "",',
	"    -- Tmux command or full path to be used",
	'    tmux_command = "tmux",',
	"    -- additional arguments for the pane if created",
	"    open_extra_args = {},",
	"    -- Expand commands, entered into the prompt",
	"    expand_command = false,",
	"    -- Close the pane on exit",
	"    close_on_exit = false,",
	"    -- Provide shell command completion for prompt",
	"    command_shell = true,",
	"    -- Find a runner by a specific query, see tmux for possible filters",
	"    runner_query = {},",
	"    -- Key combinations used",
	"    keys = {",
	"      -- for clearing the screen",
	'      clear_screen = "C-l",',
	"      -- for scrolling up in copy-mode",
	'      scroll_up = "C-u",',
	"      -- for scrolling down in copy-mode",
	'      scroll_down = "C-d",',
	"      -- for resetting the commandline (delete current line)",
	'      reset_cmdline = "C-u",',
	"      -- to interrupt runninng command",
	'      interrupt = "C-c",',
	"      -- to confirm command",
	'      confirm_command = "Enter",',
	"    },",
	"  }",
}

-- Create documentation part for commands
M.print_help = function()
	vim.api.nvim_command("botright vnew")
	local buffer_number = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"*nvimux.txt*   Run commands in tmux pane and more",
		"",
		"                                  Nvimux",
		"                   run commands in tmux panes and other stuff",
		"",
		"==============================================================================",
		"CONTENTS                                                       *nvimux-contents*",
		"",
		"    1. About............................ |NvimuxAbout|",
		"    2. Configuration ................... |NvimuxConfiguration|",
		"    3. Usage ........................... |NvimuxUsage|",
	})

	for i, cmd in ipairs(main.CMDS) do
		local space = " "
		if i < 10 then
			space = " ."
		end
		vim.api.nvim_buf_set_lines(
			buffer_number,
			-1,
			-1,
			true,
			{ "      3." .. i .. space .. string.rep(".", 29) .. " |" .. cmd["name"] .. "|" }
		)
	end

	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"",
		"",
		"==============================================================================",
		"ABOUT (1)                                                          *NvimuxAbout*",
		"",
		"Nvimux -- run commands in tmux panes and other stuff",
		"",
		"This plugin in heavily inspired by Nvimux [1], offering all the features Nvimux has",
		"offered but is written entirely in lua. Currently it focusses on the main",
		"functionalities but is intended to be extended.",
		"",
		"Like the original Nvimux Nvimux will by default create a horizontal pane with",
		"20% of your screen and execute commands in there.",
		"",
		"I appologize for the lack of documentation you might find here. The truth is",
		"in the code.",
		"",
		"[1] https://github.com/preservim/vimux",
		"",
		"",
		"==============================================================================",
		"CONFIGURATION (2)                                           *NvimuxConfiguration*",
		"",
		"Here is the default value of the configuration.",
		">",
	})
	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, default_config)
	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"<",
		"==============================================================================",
		"USAGE (3)                                                          *NvimuxUsage*",
		"",
		"The easiest way of starting a command is probably using the registered custom",
		"command:",
		">",
		"    :NvimuxRunCommand ls",
		"<",
		"Just replace `ls` with your custom command. This will create the split pane",
		"automatically and run the command in there.",
		"",
		"All the commands are wrappers around functions offered by nvimux. You can use",
		"them from you lua script, too:",
		"",
		">",
		'    :lua require("nvimux").run("ls")',
		"<",
	})

	for _, cmd in ipairs(main.CMDS) do
		vim.api.nvim_buf_set_lines(
			buffer_number,
			-1,
			-1,
			true,
			{ "------------------------------------------------------------------------------" }
		)
		vim.api.nvim_buf_set_lines(
			buffer_number,
			-1,
			-1,
			true,
			{ string.rep(" ", 78 - 2 - string.len(cmd["name"])) .. "*" .. cmd["name"] .. "*" }
		)
		vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { cmd["name"] .. "~", "" })
		local content = {}
		if cmd["description"] ~= nil then
			content = utils.prepare_text(cmd["description"])
		else
			content = { "No description available" }
		end
		vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, content)
		if cmd["example"] ~= nil then
      if type(cmd["example"]) == "table" then
        for _, ex in ipairs(cmd["example"]) do
          content = utils.prepare_text(ex, 4)
          vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", ">" })
          vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, content)
          vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "<" })
        end
      else
        content = utils.prepare_text(cmd["example"], 4)
        vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", ">" })
        vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, content)
        vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "<" })
      end
		end
		if cmd["api"] ~= nil then
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", "Lua API:" })
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { ">" })
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { '    require("nvimux").' .. cmd["api"] })
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "<" })
		end
		vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "" })
	end
	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"==============================================================================",
		"vim:tw=78:ts=2:sw=2:expandtab:ft=help:norl:",
	})
end

--Print commands for Markdown
M.print_md = function()
	vim.api.nvim_command("botright vnew")
	local buffer_number = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"# nvimux: like vimux but in lua for neovim",
		"",
		"Nvimux was inspired by Vimux, which itself was inspired by tslime.vim.",
		"It let's you interact with a tmux pane in an easy way.",
		"You can simply run commands in there, send text to it, and as an ",
		"advantage over vimux load the history into a buffer, or the quickfix list.",
		"",
		"## Installation",
		"",
		"Lazy.nvim:",
		"",
		"```lua",
		"{",
		'    "m42e/nvimux",',
		"    config=true",
		"}",
		"```",
	})

	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"",
		"## Configuration",
		"```lua",
	})
	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, default_config)
	vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, {
		"```",
		"",
		"## Commands",
	})
	for _, cmd in ipairs(main.CMDS) do
		vim.api.nvim_buf_set_lines(
			buffer_number,
			-1,
			-1,
			true,
			{ "* [" .. cmd["name"] .. "](#" .. string.lower(cmd["name"]) .. ")" }
		)
	end
	for _, cmd in ipairs(main.CMDS) do
		vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", "### " .. cmd["name"], "" })
		local content = {}
		if cmd["description"] ~= nil then
			content = utils.prepare_text(cmd["description"])
		else
			content = { "No description available" }
		end
		vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, content)
		if cmd["example"] ~= nil then
      if type(cmd["example"]) == "table" then
        for _, ex in ipairs(cmd["example"]) do
          content = utils.prepare_text(ex, 4)
          vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", "```vim" })
          vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, content)
          vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "```" })
        end
      else
        content = utils.prepare_text(cmd["example"], 4)
        vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", "```vim" })
        vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, content)
        vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "```" })
      end
		end
		if cmd["api"] ~= nil then
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "", "Lua API:" })
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "```lua" })
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { '    require("nvimux").' .. cmd["api"] })
			vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "```" })
		end
		vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, { "" })
	end
end
return M
