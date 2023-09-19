
# nvimux: like vimux but in lua for neovim

Nvimux was inspired by Vimux, which itself was inspired by tslime.vim.
It let's you interact with a tmux pane in an easy way.
You can simply run commands in there, send text to it, and as an
advantage over vimux load the history into a buffer, or the quickfix list.

## Installation

Lazy.nvim:

```lua
{
    "m42e/nvimux",
    config=true
}
```

## Configuration
```lua
  {
    -- the height/width of the pane if it has to be created
    height = '20%',
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
    -- Run in `pane` or `window`
    runner_type = "pane",
    -- Specify a specific pane/window name
    runner_name = "",
    -- Tmux command or full path to be used
    tmux_command = "tmux",
    -- additional arguments for the pane if created
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
```

## Commands
* [NvimuxRunCommand](#nvimuxruncommand)
* [NvimuxSendText](#nvimuxsendtext)
* [NvimuxSendKeys](#nvimuxsendkeys)
* [NvimuxRunLastCommand](#nvimuxrunlastcommand)
* [NvimuxOpenRunner](#nvimuxopenrunner)
* [NvimuxCloseRunner](#nvimuxcloserunner)
* [NvimuxZoomRunner](#nvimuxzoomrunner)
* [NvimuxInspectRunner](#nvimuxinspectrunner)
* [NvimuxScrollUpInspect](#nvimuxscrollupinspect)
* [NvimuxScrollDownInspect](#nvimuxscrolldowninspect)
* [NvimuxInterruptRunner](#nvimuxinterruptrunner)
* [NvimuxPromptCommand](#nvimuxpromptcommand)
* [NvimuxClearTerminalScreen](#nvimuxclearterminalscreen)
* [NvimuxClearRunnerHistory](#nvimuxclearrunnerhistory)
* [NvimuxTogglePane](#nvimuxtogglepane)
* [NvimuxLog](#nvimuxlog)
* [NvimuxLoadPane](#nvimuxloadpane)
* [NvimuxQuickFix](#nvimuxquickfix)

### NvimuxRunCommand

Run a shell command in an extra pane.

```vim
    " Run the current file with rspec
    vim.keymap.set("n", "<leader>vl", require("nvimux").run("clear; rspec " . bufname("%")), {})
```

Lua API:
```lua
    require("nvimux").run(command, autoreturn)
```


### NvimuxSendText

Sends text, as it is to the runner pane if there is one opened.
Interacts with any program or shell waiting for input.

```vim
    " Send the content of the " register to the pane
    local get_reg = function()
      return vim.api.nvim_exec(\[\[echo getreg('\]\]..char..\[\[')\]\], true):gsub("[\n\r]", "^J")
    end
    vim.keymap.set("n", "<leader>P", require("nvimux").send_keys(get_reg("\"")), {})
```

Lua API:
```lua
    require("nvimux").send_text(your_string)
```


### NvimuxSendKeys

Sends key or keycombination (such ash C-u for Ctrl+u) to the runner pane if there is one opened.
Interacts with any program or shell waiting for input.

Lua API:
```lua
    require("nvimux").send_keys(key)
```


### NvimuxRunLastCommand

Reruns the last command run with either |NvimuxRunCommand| or |NvimuxPromptCommand|

Lua API:
```lua
    require("nvimux").run_last()
```


### NvimuxOpenRunner

No description available

Lua API:
```lua
    require("nvimux").open()
```


### NvimuxCloseRunner

Closes the open runner, if there is one.

Lua API:
```lua
    require("nvimux").close_runner()
```


### NvimuxZoomRunner

Zooms the runner, like the "<bindkey> z", which you can then use to unzoom.

Lua API:
```lua
    require("nvimux").zoom_runner()
```


### NvimuxInspectRunner

Puts the runnter into inspect/copy-mode, to scroll around

Lua API:
```lua
    require("nvimux").inspect_runner()
```


### NvimuxScrollUpInspect

Puts the runnter into inspect/copy-mode if needed and scroll up.

Lua API:
```lua
    require("nvimux").inspect_scroll_up()
```


### NvimuxScrollDownInspect

Puts the runnter into inspect/copy-mode if needed and scroll down.

Lua API:
```lua
    require("nvimux").inspect_scroll_down()
```


### NvimuxInterruptRunner

Sends Ctrl-c, to the running process in the open pane.

Lua API:
```lua
    require("nvimux").interrupt_runner()
```


### NvimuxPromptCommand

Opens a prompt to be filled, allows to add some prefix command.

Lua API:
```lua
    require("nvimux").prompt_command(<prefix>)
```


### NvimuxClearTerminalScreen

Clears the screen in the pane.

Lua API:
```lua
    require("nvimux").clear_terminal_screen()
```


### NvimuxClearRunnerHistory

Clears the tmux history in the pane.

Lua API:
```lua
    require("nvimux").clear_history()
```


### NvimuxTogglePane

Makes a pane a window and vice versa, will not change the settings.

Lua API:
```lua
    require("nvimux").toggle()
```


### NvimuxLog

Print the stored log entries of nvimux.


### NvimuxLoadPane

This will load all the history of a pane up to the numer of lines, or all if not specified, into a buffer.

Lua API:
```lua
    require("nvimux").toggle()
```


### NvimuxQuickFix

This will load all the history of a pane up to the numer of lines, or all if not specified into the quickfix list
The first argument is the number of lines, the second one is a specific errorformat, else the default will be used.

Lua API:
```lua
    require("nvimux").toggle()
```

