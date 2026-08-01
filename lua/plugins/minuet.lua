local ai_filetypes = {
  "css",
  "go",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "lua",
  "markdown",
  "markdown.mdx",
  "mdx",
  "python",
  "typescript",
  "typescriptreact",
}

local llamacpp = {
  provider = "openai_compatible",
  request_timeout = 3,
  -- Keep AI ghost text responsive while still avoiding a request on every keypress.
  throttle = 1000,
  debounce = 300,
  -- Match the mature inline-completion UX: show one best ghost-text suggestion
  -- instead of making the user cycle through multiple AI alternatives.
  n_completions = 1,
  -- Use a Copilot-like prompt budget for the local endpoint, where larger
  -- context is cheaper and the model/server can handle a wider window.
  context_window = 8192,
  virtualtext = {
    auto_trigger_ft = ai_filetypes,
    keymap = {
      -- Mirror Blink completion keys so both completion UIs share one muscle memory.
      accept = "<C-y>",
      dismiss = "<C-e>",
      next = "<C-n>",
      prev = "<C-p>",
    },
    show_on_completion_menu = false,
  },
  provider_options = {
    openai_compatible = {
      name = "llama.cpp",
      api_key = function()
        return vim.env.LLAMACPP_API_KEY or "local"
      end,
      end_point = "https://llamacpp-stack.vex9z7.com/v1/chat/completions",
      model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF/UD-Q4_K_M",
      optional = {
        stream = true,
        max_tokens = 500,
        top_p = 0.9,
        chat_template_kwargs = {
          enable_thinking = false,
        },
      },
    },
  },
}

local deepseek = vim.tbl_deep_extend("force", llamacpp, {
  provider = "openai_fim_compatible",
  request_timeout = 3,
  -- Keep AI ghost text responsive while still avoiding a request on every keypress.
  throttle = 1000,
  debounce = 300,
  n_completions = 1,
  context_window = 8192,
  provider_options = {
    openai_fim_compatible = {
      name = "deepseek",
      api_key = "DEEPSEEK_API_KEY",
      end_point = "https://api.deepseek.com/beta/completions",
      model = "deepseek-v4-flash",
      optional = {
        stream = true,
        max_tokens = 500,
        top_p = 0.9,
      },
    },
  },
})

return {
  {
    "milanglacier/minuet-ai.nvim",
    main = "minuet",
    event = "InsertEnter",
    opts = vim.tbl_deep_extend("force", llamacpp, {
      presets = {
        llamacpp = llamacpp,
        deepseek = deepseek,
      },
    }),
  },
}
