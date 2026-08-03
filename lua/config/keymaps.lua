-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Avoid terminal Alt-key encoding turning a quick Escape followed by j/k into line moves.
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

Snacks.toggle({
  name = "Git Diff Overlay",
  get = function()
    local ok, inlinediff = pcall(require, "inlinediff")
    return ok and inlinediff.enabled or false
  end,
  set = function(state)
    local inlinediff = require "inlinediff"
    if inlinediff.enabled ~= state then
      inlinediff.toggle()
    end
  end,
}):map "<leader>uo"
