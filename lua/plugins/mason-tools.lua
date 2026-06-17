return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      -- CLI formatters and autofix tools used by conform.nvim in lua/plugins/conform.lua.
      -- Ruff is also used by LazyVim's Python LSP extra for diagnostics and code actions.
      vim.list_extend(opts.ensure_installed, {
        "eslint_d",
        "prettierd",
        "ruff",
      })
    end,
  },
}
