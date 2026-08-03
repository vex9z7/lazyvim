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
        "<leader>ac",
        function()
          require("plugins.agentic.context").pick()
        end,
        mode = "n",
        desc = "Pick Agentic context action",
      },
      {
        "<leader>ac",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = "v",
        desc = "Add selection to Agentic",
      },
      {
        "<leader>as",
        function()
          require("plugins.agentic.sessions").pick()
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
    },
    opts = {
      provider = "opencode-acp",
      diff_preview = {
        layout = "inline",
      },
      provider_switcher = {
        hide_unhealthy_providers = true,
      },
    },
  },
}
