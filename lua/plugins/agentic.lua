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
        "<leader>an",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v" },
        desc = "New Agentic session",
      },
      {
        "<leader>ar",
        function()
          require("agentic").restore_session()
        end,
        mode = { "n", "v" },
        desc = "Restore Agentic session",
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
      provider = "pi-acp",
      acp_providers = {
        ["pi-acp"] = {
          name = "Pi ACP",
          command = "pi-acp",
          env = {
            PI_ACP_PI_COMMAND = vim.fn.stdpath "config" .. "/bin/pi-agentic",
          },
        },
        ["opencode-acp"] = {
          name = "OpenCode ACP",
          command = vim.fn.stdpath "config" .. "/bin/opencode-agentic",
          args = { "acp" },
          env = {},
        },
      },
      diff_preview = {
        enabled = true,
        layout = "inline",
      },
      windows = {
        position = "right",
        width = "38%",
      },
    },
  },
}
