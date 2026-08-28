return {
  {
    "GCBallesteros/NotebookNavigator.nvim",
    ft = "python",
    dependencies = { "benlubas/molten-nvim" },
    opts = {
      repl_provider = "molten",
      syntax_highlight = true,
    },
    keys = {
      {
        "[j",
        function()
          require("notebook-navigator").move_cell "u"
        end,
        desc = "Previous Python Cell",
        ft = "python",
      },
      {
        "]j",
        function()
          require("notebook-navigator").move_cell "d"
        end,
        desc = "Next Python Cell",
        ft = "python",
      },
      {
        "<leader>je",
        function()
          require("config.python").run_cell()
        end,
        desc = "Evaluate Python Cell",
        ft = "python",
      },
      {
        "<leader>jE",
        function()
          require("config.python").run_cells_above()
        end,
        desc = "Evaluate Python Cells Above",
        ft = "python",
      },
    },
  },
}
