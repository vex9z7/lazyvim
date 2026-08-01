return {
  {
    "YouSame2/inlinediff-nvim",
    cmd = "InlineDiff",
    keys = {
      {
        "<leader>go",
        function()
          require("inlinediff").toggle()
        end,
        desc = "Toggle Git Diff Overlay",
      },
    },
    opts = {
      debounce_time = 200,
      ignored_buftype = { "terminal", "nofile" },
      ignored_filetype = {
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
      },
    },
  },
}
