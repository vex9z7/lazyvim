return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        -- Let Oil handle directory buffers such as `nvim .` and `:edit .`.
        replace_netrw = false,
      },
    },
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    lazy = false,
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Explorer Oil" },
      {
        "<leader>E",
        function()
          require("oil").toggle_float()
        end,
        desc = "Explorer Oil Float",
      },
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
      },
      view_options = {
        show_hidden = false,
        natural_order = true,
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },
    },
  },
}
