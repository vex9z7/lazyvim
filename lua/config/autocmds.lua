-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- `autoread` only reloads after Neovim checks the file. LazyVim checks on focus
-- changes; also check while idle so edits made by an agent or another process appear.
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("config_checktime", { clear = true }),
  command = "checktime",
})
