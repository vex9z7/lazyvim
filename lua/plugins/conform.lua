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

local clang_format_changed = require "local.clang-format-changed"

local function clang_formatters(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local config = path ~= ""
    and vim.fs.find({ ".clang-format", "_clang-format" }, {
      path = vim.fs.dirname(path),
      upward = true,
      limit = 1,
    })[1]
  if config then
    if clang_format_changed.is_llama_cpp(path) then
      return { "clang_format_changed", lsp_format = "never" }
    end
    return { "clang_format", lsp_format = "never" }
  end
  return { lsp_format = "never" }
end

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

      -- llama.cpp intentionally leaves legacy code untouched. Format only the
      -- ranges changed since the previous write, while retaining Conform's
      -- normal format-on-save lifecycle and minimal buffer edits.
      opts.formatters.clang_format_changed = {
        condition = function(_, ctx)
          return clang_format_changed.is_llama_cpp(ctx.filename)
        end,
        format = function(_, ctx, lines, callback)
          clang_format_changed.format(ctx.filename, lines, { bufnr = ctx.buf, formatdiff = true }, callback)
        end,
      }

      -- Only format C/C++ when a project explicitly supplies its style.
      -- clangd formatting shares clang-format's LLVM fallback, so disable both paths otherwise.
      opts.formatters_by_ft.c = clang_formatters
      opts.formatters_by_ft.cpp = clang_formatters
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
