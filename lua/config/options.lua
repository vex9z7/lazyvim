-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Prefer an isolated Python host for Python-based Neovim plugins when available.
local python_host = vim.fn.stdpath "data" .. "/python/bin/python"
if vim.fn.executable(python_host) == 1 then
  vim.g.python3_host_prog = python_host
end

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

-- Keep context around the cursor and make long lines wrap visually without
-- inserting hard line breaks.
vim.o.scrolloff = 10
vim.o.textwidth = 0
vim.o.wrap = true
vim.o.linebreak = true
vim.o.showbreak = " 󱞩 "

-- Use two-space indentation and insert spaces when pressing Tab.
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Configure explicit system clipboard integration across local, SSH, and tmux sessions.
require "config.clipboard"

-- Let conform handle save-time ESLint fixes while ESLint LSP provides diagnostics and code actions.
vim.g.lazyvim_eslint_auto_format = false

-- Use Pyright for Python language intelligence and Ruff LSP for diagnostics and code actions.
-- Save-time Python lint autofix and formatting are handled by conform.nvim.
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
