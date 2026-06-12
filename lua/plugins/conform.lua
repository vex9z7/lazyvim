local prettier_filetypes = {
  "css",
  "graphql",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "mdx",
  "typescript",
  "typescriptreact",
}

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "black",
        "eslint_d",
        "prettierd",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters_by_ft.python = { "black" }

      for _, ft in ipairs { "javascript", "javascriptreact", "typescript", "typescriptreact" } do
        opts.formatters_by_ft[ft] = { "eslint_d", "prettierd" }
      end

      for _, ft in ipairs(prettier_filetypes) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or { "prettierd" }
      end
    end,
  },
}
