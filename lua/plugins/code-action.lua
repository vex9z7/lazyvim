local function kind_rank(kind)
  kind = kind or ""

  if kind == "quickfix" or vim.startswith(kind, "quickfix.") then
    return 10
  end
  if kind == "refactor" or vim.startswith(kind, "refactor.") then
    return 20
  end
  if kind == "source" or vim.startswith(kind, "source.") then
    return 30
  end

  return 40
end

local function action_rank(item)
  if item.action.disabled then
    return 90
  end

  return kind_rank(item.action.kind)
end

local function set_code_action_keymap(buf)
  vim.keymap.set({ "n", "x" }, "<leader>ca", function()
    require("tiny-code-action").code_action()
  end, { buffer = buf, desc = "Code Action" })
end

return {
  {
    "rachartier/tiny-code-action.nvim",
    event = "LspAttach",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("tiny-code-action-keymaps", { clear = true }),
        callback = function(event)
          set_code_action_keymap(event.buf)
        end,
      })

      vim.schedule(function()
        for _, client in ipairs(vim.lsp.get_clients()) do
          for buf in pairs(client.attached_buffers or {}) do
            set_code_action_keymap(buf)
          end
        end
      end)
    end,
    opts = {
      backend = "vim",
      picker = {
        "buffer",
        opts = {
          hotkeys = true,
          hotkeys_mode = "text_diff_based",
          auto_preview = true,
          position = "cursor",
        },
      },
      -- Prefer local fixes before file-level source actions in the code-action menu.
      sort = function(a, b)
        local a_rank = action_rank(a)
        local b_rank = action_rank(b)
        if a_rank ~= b_rank then
          return a_rank < b_rank
        end

        local a_preferred = a.action.isPreferred and 0 or 1
        local b_preferred = b.action.isPreferred and 0 or 1
        if a_preferred ~= b_preferred then
          return a_preferred < b_preferred
        end

        local a_title = a.action.title or ""
        local b_title = b.action.title or ""
        return a_title < b_title
      end,
    },
  },
}
