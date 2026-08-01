return {
  {
    "nvim-mini/mini.diff",
    version = false,
    keys = {
      {
        "<leader>go",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_is_loaded(bufnr) then
            require("mini.diff").toggle_overlay(bufnr)
          end
        end,
        desc = "Toggle Git Diff Overlay",
      },
    },
    opts = {
      -- Keep gitsigns responsible for signs and hunk operations; use mini.diff
      -- only as an on-demand inline overlay for reviewing changes in narrow panes.
      view = {
        style = "sign",
      },
      mappings = {
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
    },
  },
}
