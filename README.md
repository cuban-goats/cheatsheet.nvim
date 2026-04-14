# cheatsheet.nvim

Quickly access cheatsheets in nvim

## Requirements

- nvim neotree


## Setup
- set a FilePath for your default Cheatsheet (line 124 lua/cheatsheet/init.lua):

Example

- set your Directory containing all of your cheatsheets in opts
- set the default cheatsheet
- example Opts

Example

```lua
return {
  "cuban-goats/cheatsheet.nvim"
  opts = {
    cheatDir = "/Users/./Desktop/./cheatsheets",
    default = "cheatsheet.typ"
  }
}

```

