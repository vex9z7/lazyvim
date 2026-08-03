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

      vim.list_extend(opts.servers["*"].keys, {
        {
          "gd",
          function()
            Snacks.picker.lsp_definitions()
          end,
          desc = "Goto Definition",
          has = "definition",
        },
        {
          "grr",
          function()
            Snacks.picker.lsp_references()
          end,
          desc = "References",
          has = "references",
        },
        {
          "gri",
          function()
            Snacks.picker.lsp_implementations()
          end,
          desc = "Goto Implementation",
          has = "implementation",
        },
        {
          "grt",
          function()
            Snacks.picker.lsp_type_definitions()
          end,
          desc = "Goto Type Definition",
          has = "typeDefinition",
        },
      })
    end,
  },
}
