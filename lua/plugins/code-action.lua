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

local function preview_rank(action)
  if action.edit then
    return 0
  end
  return 1
end

local function action_rank(item)
  if item.action.disabled then
    return 90
  end

  return kind_rank(item.action.kind) + preview_rank(item.action)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local keys = opts.servers["*"].keys
      for index = #keys, 1, -1 do
        local lhs = keys[index][1]
        if lhs == "<leader>ca" or lhs == "<leader>cA" then
          table.remove(keys, index)
        end
      end

      -- Use one code-action UI for both all actions and source-only actions.
      table.insert(keys, {
        "<leader>ca",
        function()
          require("tiny-code-action").code_action()
        end,
        desc = "Code Action",
        mode = { "n", "x" },
        has = "codeAction",
      })
      table.insert(keys, {
        "<leader>cA",
        function()
          require("tiny-code-action").code_action { context = { only = { "source" } } }
        end,
        desc = "Source Action",
        mode = { "n", "x" },
        has = "codeAction",
      })
    end,
  },
  {
    "rachartier/tiny-code-action.nvim",
    event = "LspAttach",
    opts = {
      backend = "vim",
      picker = "snacks",
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
