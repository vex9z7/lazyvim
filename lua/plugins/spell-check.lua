return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      -- Code-aware spell checker used through nvim-lspconfig's codebook server.
      vim.list_extend(opts.ensure_installed, { "codebook" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require "lspconfig.util"

      opts.servers = opts.servers or {}
      opts.servers.codebook = {
        -- Use the normal LSP attach path while Mason only manages the binary installation.
        mason = false,
        init_options = {
          -- Keep personal fallback dictionaries portable with this Neovim config.
          globalConfigPath = vim.fn.stdpath "config" .. "/tool-config/codebook/codebook.toml",
        },
        -- Prefer project Codebook config before falling back to the repository root.
        root_dir = function(bufnr, on_dir)
          on_dir(util.root_pattern("codebook.toml", ".codebook.toml", ".git")(vim.api.nvim_buf_get_name(bufnr)))
        end,
      }
    end,
  },
}
