return {
  {
    "YouSame2/inlinediff-nvim",
    cmd = "InlineDiff",
    init = function()
      require("lazyvim.util").on_very_lazy(function()
        Snacks.toggle({
          name = "Git Diff Overlay",
          get = function()
            local ok, inlinediff = pcall(require, "inlinediff")
            return ok and inlinediff.enabled or false
          end,
          set = function(state)
            local inlinediff = require "inlinediff"
            if inlinediff.enabled ~= state then
              inlinediff.toggle()
            end
          end,
        }):map "<leader>go"
      end)
    end,
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
