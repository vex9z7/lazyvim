-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show absolute line number for the current line and relative line numbers for
-- surrounding lines, which makes count-based motions easier.
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse support for clicking, selecting, and resizing splits.
vim.o.mouse = "a"

-- Hide the built-in mode text because the statusline already shows the current mode.
vim.o.showmode = false

-- Persist undo history across Neovim sessions and keep a deep undo tree.
vim.o.undofile = true
vim.o.undolevels = 10000
vim.o.undoreload = 10000

-- Show invisible whitespace characters so indentation and stray spaces are visible.
vim.o.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  space = "·",
  nbsp = "␣",
  extends = "⟩",
  precedes = "⟨",
}

-- Configure system clipboard integration, including OSC52 clipboard support over SSH.
require("config.clipboard")
