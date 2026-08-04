return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>K",
        function()
          require("local.ai_explain").followup()
        end,
        desc = "Ask about code explanation",
      },
    },
    init = function()
      require("local.ai_explain").setup()
    end,
  },
}
