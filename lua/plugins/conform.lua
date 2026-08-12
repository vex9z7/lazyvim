local js_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

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
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters = opts.formatters or {}

      -- Format fenced code blocks with safe formatters for snippets.
      -- Do not run lint autofixers such as eslint_d inside Markdown examples.
      opts.formatters.injected = {
        options = {
          lang_to_formatters = {
            javascript = { "prettierd" },
            typescript = { "prettierd" },
            lua = { "stylua" },
            python = { "ruff_format" },
          },
        },
      }

      -- Project-local .clang-format / cmakelang config discovery remains authoritative.
      -- Do not supply a global style or config file here.
      opts.formatters_by_ft.c = { "clang_format" }
      opts.formatters_by_ft.cpp = { "clang_format" }
      opts.formatters_by_ft.cmake = { "cmake_format" }

      -- Run Ruff lint autofix before Ruff formatting on save.
      -- Requires the Mason-managed Ruff CLI from lua/plugins/mason-tools.lua.
      opts.formatters_by_ft.python = { "ruff_fix", "ruff_format" }

      -- Requires the Mason-managed eslint_d and prettierd CLI formatters from lua/plugins/mason-tools.lua.
      for _, ft in ipairs(js_filetypes) do
        opts.formatters_by_ft[ft] = { "eslint_d", "prettierd" }
      end

      -- Requires the Mason-managed prettierd CLI formatter from lua/plugins/mason-tools.lua.
      for _, ft in ipairs(prettier_filetypes) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or { "prettierd" }
      end

      -- Format fenced code blocks on save for prose documents.
      opts.formatters_by_ft.markdown = { "prettierd", "injected" }
      opts.formatters_by_ft["markdown.mdx"] = { "prettierd", "injected" }
      opts.formatters_by_ft.mdx = { "prettierd", "injected" }
    end,
  },
}
