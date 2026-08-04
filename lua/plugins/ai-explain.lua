return {
  {
    "folke/snacks.nvim",
    init = function()
      require("local.ai_explain").setup()
    end,
  },
}
