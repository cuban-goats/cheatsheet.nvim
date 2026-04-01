# cheatsheet.nvim

Quickly access cheatsheets in nvim

## Requirements

- nvim neotree


## Setup
- set a FilePath for your default Cheatsheet (line 124 lua/cheatsheet/init.lua):

Example

```lua
vim.cmd("split ~/Desktop/theorie/cheatsheets/cheatsheet.typ")

```

- set your Directory containing all of your cheatsheets in opts
- example Opts

Example

```lua
return {
  dir = "~/Desktop/dev/nvimplugins/cheatsheet.nvim",
  opts = {
    cheatDir = "/Users/I767435/Desktop/theorie/cheatsheets",
    preview = "false",
  }
}

```

