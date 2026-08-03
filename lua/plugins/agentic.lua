return {
  {
    "carlos-algms/agentic.nvim",
    keys = {
      {
        "<leader>aa",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v" },
        desc = "Toggle Agentic chat",
      },
      {
        "<leader>aA",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file/selection to Agentic",
      },
      {
        "<leader>as",
        function()
          require("local.agentic-sessions").pick()
        end,
        mode = { "n", "v" },
        desc = "Pick Agentic session",
      },
      {
        "<leader>ap",
        function()
          require("agentic").switch_provider()
        end,
        mode = { "n", "v" },
        desc = "Switch Agentic provider",
      },
      {
        "<leader>ad",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = "n",
        desc = "Add line diagnostics to Agentic",
      },
      {
        "<leader>aD",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = "n",
        desc = "Add buffer diagnostics to Agentic",
      },
    },
    opts = {
      provider = "opencode-acp",
      diff_preview = {
        layout = "inline",
      },
    },
  },
}
