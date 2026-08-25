return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      -- Marksman uses the repository root for cross-file Markdown links.
      opts.servers.marksman = {}
    end,
  },
}
