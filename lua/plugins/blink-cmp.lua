return {
  {
    "saghen/blink.cmp",
    opts = {
      fuzzy = {
        -- Use the pure Lua matcher so completion does not depend on downloading
        -- or building blink.cmp's optional native matcher.
        implementation = "lua",
      },
      completion = {
        ghost_text = {
          -- Preview the selected completion item inline while keeping acceptance
          -- and navigation on the normal Blink completion keys.
          enabled = true,
          show_with_selection = true,
          show_without_selection = false,
        },
      },
      keymap = {
        ["<C-y>"] = {
          function()
            return require("plugins.minuet.keymap").accept()
          end,
          "select_and_accept",
          "fallback",
        },
        ["<C-e>"] = {
          function()
            return require("plugins.minuet.keymap").dismiss()
          end,
          "cancel",
          "fallback",
        },
        ["<C-n>"] = {
          function()
            return require("plugins.minuet.keymap").next()
          end,
          "select_next",
          "fallback_to_mappings",
        },
        ["<C-p>"] = {
          function()
            return require("plugins.minuet.keymap").prev()
          end,
          "select_prev",
          "fallback_to_mappings",
        },
      },
      signature = {
        enabled = false,
      },
    },
  },
}
