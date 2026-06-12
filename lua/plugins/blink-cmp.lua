return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Use the pure Lua matcher so completion does not depend on downloading
      -- or building blink.cmp's optional native matcher.
      fuzzy = { implementation = "lua" },
      -- Show function signatures while typing call arguments.
      signature = { enabled = true },
    },
  },
}
