return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        layout = {
          -- Use a Telescope-like layout when there is enough horizontal space:
          -- compact results/input on the left, preview as the main reading area on the right.
          preset = function()
            return vim.o.columns >= 100 and "compact_preview" or "compact_preview_vertical"
          end,
        },
        layouts = {
          compact_preview = {
            reverse = true,
            layout = {
              box = "horizontal",
              backdrop = false,
              width = 0.96,
              height = 0.92,
              border = "none",
              {
                box = "vertical",
                width = 0.34,
                { win = "list", title = " Results ", title_pos = "center", border = true },
                { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
              },
              { win = "preview", title = "{preview:Preview}", title_pos = "center", border = true },
            },
          },
          compact_preview_vertical = {
            reverse = true,
            layout = {
              box = "vertical",
              backdrop = false,
              width = 0.96,
              height = 0.92,
              border = "none",
              { win = "preview", title = "{preview:Preview}", title_pos = "center", border = true, height = 0.62 },
              { win = "list", title = " Results ", title_pos = "center", border = true },
              { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
            },
          },
          compact_no_preview = {
            reverse = true,
            layout = {
              box = "vertical",
              backdrop = false,
              width = 0.96,
              height = 0.7,
              border = "none",
              { win = "list", title = " Items ", title_pos = "center", border = true },
              { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
            },
          },
        },
        sources = {
          agentic_context_actions = {
            layout = { preset = "compact_no_preview" },
            preview = "none",
            main = { current = false },
            matcher = { sort_empty = false },
            sort = { fields = { "idx" } },
          },
          agentic_sessions = {
            layout = { preset = "compact_no_preview" },
            preview = "none",
            main = { current = false },
            matcher = { sort_empty = false },
            sort = { fields = { "idx" } },
          },
        },
      },
    },
  },
}
