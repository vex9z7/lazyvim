-- Use the system clipboard as the default register so normal yank, delete, and
-- paste operations integrate with the surrounding desktop or terminal.
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"

  -- Let Neovim choose the local clipboard provider when possible, such as
  -- wl-copy on Wayland, xclip/xsel on X11, or tmux in terminal sessions.
  -- Over SSH, use OSC52 explicitly so yanks can reach the client clipboard.
  if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
    local osc52 = require("vim.ui.clipboard.osc52")

    vim.g.clipboard = {
      name = "osc52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = function()
          return vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"')
        end,
        ["*"] = function()
          return vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"')
        end,
      },
    }
  end
end)
