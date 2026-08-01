return {
  {
    "formatter-daemon-warmup",
    dir = vim.fn.stdpath "config" .. "/lua/local/formatter-daemon-warmup",
    main = "local.formatter-daemon-warmup",
    event = "VeryLazy",
    opts = {},
  },
}
