return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      -- CLI formatters used by conform.nvim in lua/plugins/conform.lua.
      vim.list_extend(opts.ensure_installed, {
        "black",
        "eslint_d",
        "prettierd",
      })
    end,
  },
}
