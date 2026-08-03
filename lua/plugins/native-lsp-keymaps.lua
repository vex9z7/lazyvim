return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      for index, key in ipairs(opts.servers["*"].keys or {}) do
        if key[1] == "gr" then
          table.remove(opts.servers["*"].keys, index)
          break
        end
      end
    end,
  },
}
