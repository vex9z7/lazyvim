return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Use the pure Lua matcher so completion does not depend on downloading
      -- or building blink.cmp's optional native matcher.
      opts.fuzzy = vim.tbl_deep_extend("force", opts.fuzzy or {}, { implementation = "lua" })

      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        ghost_text = {
          -- Preview the selected completion item inline while keeping acceptance
          -- and navigation on the normal Blink completion keys.
          enabled = true,
          show_with_selection = true,
          show_without_selection = false,
        },
      })

      -- Show function signatures while typing call arguments.
      opts.signature = vim.tbl_deep_extend("force", opts.signature or {}, { enabled = true })
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(event)
          if event.data == "blink.cmp" then
            require("local.ai-completion-keys").setup()
          end
        end,
      })
    end,
  },
}
