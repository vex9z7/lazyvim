return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      for index = #(opts.servers["*"].keys or {}), 1, -1 do
        local key = opts.servers["*"].keys[index]
        if key[1] == "gr" or key[1] == "<leader>cr" then
          table.remove(opts.servers["*"].keys, index)
        end
      end
    end,
  },
}
