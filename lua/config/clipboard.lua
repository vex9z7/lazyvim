-- Make normal yanks, deletes, and pastes use the system clipboard register.
-- LazyVim leaves 'clipboard' empty over SSH; this config prefers explicit
-- clipboard behavior while still using Neovim's built-in providers.
local function is_ssh()
  return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
end

local function is_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function setup_clipboard()
  -- Use Neovim's built-in provider detection locally and inside tmux. Modern
  -- Neovim has a tmux provider that uses `tmux load-buffer -w -` when available.
  vim.g.clipboard = false

  -- Outside tmux, SSH sessions usually need OSC52 to reach the client clipboard.
  if is_ssh() and not is_tmux() then
    vim.g.clipboard = "osc52"
  end

  vim.o.clipboard = "unnamedplus"
end

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("dotnvim_clipboard", { clear = true }),
  pattern = "VeryLazy",
  once = true,
  callback = function()
    -- Run after other VeryLazy handlers so this override wins over LazyVim's
    -- SSH clipboard default.
    vim.schedule(setup_clipboard)
  end,
})
