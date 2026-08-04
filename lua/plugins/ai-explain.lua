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
      require("local.ai_explain").setup {
        language = "en",
        languages = {
          en = {
            name = "English",
            max_characters = 100,
            example = "Maps characters to integer tokens for later tensor conversion.",
          },
          zh = {
            name = "Simplified Chinese",
            max_characters = 60,
            example = "将字符映射为整数 token，供后续张量化使用。",
          },
        },
      }
    end,
  },
}
