return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Use the pure Lua matcher so completion does not depend on downloading
      -- or building blink.cmp's optional native matcher.
      fuzzy = { implementation = "lua" },
      completion = {
        ghost_text = {
          -- Preview the selected completion item inline while keeping acceptance
          -- and navigation on the normal Blink completion keys.
          enabled = true,
          show_with_selection = true,
          show_without_selection = false,
        },
      },
      -- Show function signatures while typing call arguments.
      signature = { enabled = true },
    },
  },
}
