return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        layout = {
          -- Use a Telescope-like layout when there is enough horizontal space:
          -- compact results/input on the left, preview as the main reading area on the right.
          preset = function()
            return vim.o.columns >= 100 and "compact_preview" or "vertical"
          end,
        },
        layouts = {
          compact_preview = {
            reverse = true,
            layout = {
              box = "horizontal",
              backdrop = false,
              width = 0.96,
              height = 0.86,
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
        },
      },
    },
  },
}
