return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/flash.nvim",
    keys = {
      -- TODO: Consider moving back to LazyVim's mini.surround extra later for
      -- better LazyVim keymap compatibility. For now, keep nvim-surround's
      -- visual-mode S mapping because it matches existing surround muscle memory.
      { "S", false, mode = "x" },
    },
  },
}
