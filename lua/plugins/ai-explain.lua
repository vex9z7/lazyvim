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
        endpoint = "https://llamacpp-stack.vex9z7.com/v1/chat/completions",
        model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF/UD-Q4_K_M",
        api_key_env = "LLAMACPP_API_KEY",
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
