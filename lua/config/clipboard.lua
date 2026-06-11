-- Make normal yanks, deletes, and pastes use the system clipboard register.
-- Provider selection stays delegated to Neovim, except plain SSH sessions use
-- OSC52 explicitly so copies can reach the client terminal clipboard.
local function is_ssh()
  return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
end

local function is_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function setup_clipboard()
  -- Let Neovim choose the provider locally and inside tmux. Its built-in tmux
  -- provider can forward yanks with `tmux load-buffer -w -` when supported.
  vim.g.clipboard = false

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
    -- Apply after lazy-loaded defaults so the explicit clipboard preference wins.
    vim.schedule(setup_clipboard)
  end,
})
