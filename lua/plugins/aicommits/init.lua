return {
  {
    "404pilo/aicommits.nvim",
    cmd = { "AICommit", "AICommitHealth", "AICommitDebug" },
    config = function(_, opts)
      require("plugins.aicommits.openai_extra_body").setup()
      require("aicommits").setup(opts)
    end,
    opts = {
      active_provider = "openai",
      providers = {
        openai = {
          api_key = vim.env.AICOMMITS_NVIM_OPENAI_API_KEY or vim.env.LLAMACPP_API_KEY or "local",
          endpoint = "https://llamacpp-stack.vex9z7.com/v1/chat/completions",
          model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF/UD-Q4_K_M",
          generate = 3,
          max_length = 72,
          max_tokens = 200,
          temperature = 0.3,
          extra_body = {
            chat_template_kwargs = {
              enable_thinking = false,
            },
          },
        },
      },
      ui = {
        use_custom_picker = true,
      },
      integrations = {
        neogit = {
          enabled = false,
        },
      },
    },
  },
}
