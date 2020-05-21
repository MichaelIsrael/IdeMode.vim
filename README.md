# VimIdeMode
A vim plugin to turn a vim session to an IDE-like mode.

# Features
* A file explorer.
* A list of opened and visible buffers.
* Switching to a certain buffer in the last selected window.
* A terminal.
* Starts Tagbar (if available)

# Activating
The IDE-Mode can be toggled using the command:
```vim
:IdeModeToggle
```

*for now there are no key-mappings to toggle the IDE-Mode. I would suggest adding the following to your .vimrc:
```vim
nmap <M-i> :IdeModeToggle<CR>
```
This way it can be toggled using alt-i (stands for IDE).*

# Configuration
the following global variables can be defined in vimrc to control a few things in the IDE-Mode behavior:

## g:IdeMode_linenumber
Set to 0 to disable setting number when starting the IDE-Mode. Default is enabled (1).
example:
```vim
let g:IdeMode_linenumber = 0
```

## g:IdeMode_terminal
Defines what command will be used to start a terminal. If nothing was set, it will be checked if "term" is supported, otherwise "Terminal" will be checked. If none of them, no terminal will be activated.
Example:
```vim
let g:IdeMode_terminal = "Terminal"
```

## g:IdeMode_shell
Defines what shell to be used in the terminal (if active). In other words, this is what will be started in the terminal. Default is bash (regardless of the OS).
Example:
```vim
let g:IdeMode_shell = "zsh"
```
or even:
```vim
let g:IdeMode_shell = "python3"
```
