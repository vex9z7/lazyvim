local denied_buftypes = {
  help = true,
  prompt = true,
  quickfix = true,
  terminal = true,
}

local denied_filetypes = {
  help = true,
  lazy = true,
  mason = true,
  qf = true,
}

-- AI context exclusion patterns. These are path rules for files whose contents
-- should not be sent to completion providers during automatic ghost text.
local denied_path_patterns = {
  -- Secrets and local credentials.
  "/%.env$",
  "/%.env%.",
  "/%.aws/",
  "/%.gnupg/",
  "/%.kube/",
  "/%.ssh/",
  "/secret/",
  "/secrets/",
  "/%.secret/",
  "/%.secrets/",
  "/credentials[^/]*$",
  "/secret%.[^/]+$",
  "/secrets%.[^/]+$",
  "%.key$",
  "%.pem$",
  "%.p12$",
  "%.pfx$",

  -- Generated or data-heavy files where inline AI completion is low value.
  "/package%-lock%.json$",
  "/pnpm%-lock%.yaml$",
  "/yarn%.lock$",
  "/cargo%.lock$",
  "%.min%.css$",
  "%.min%.js$",
  "%.csv$",
  "%.dump$",
  "%.log$",
}

local function normalize_path(path)
  return path:gsub("\\", "/"):lower()
end

local function path_matches_any(path, patterns)
  local normalized = normalize_path(path)

  for _, pattern in ipairs(patterns) do
    if normalized:find(pattern) then
      return true
    end
  end

  return false
end

local function ai_completion_allowed()
  if denied_buftypes[vim.bo.buftype] or denied_filetypes[vim.bo.filetype] then
    return false
  end

  if not vim.bo.modifiable then
    return false
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path ~= "" and path_matches_any(path, denied_path_patterns) then
    return false
  end

  return true
end

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

local function enable_current_buffer_auto_trigger()
  -- Minuet sets this from a FileType autocmd, but this plugin lazy-loads on
  -- InsertEnter, after the current buffer's FileType event has usually fired.
  if vim.tbl_contains(ai_filetypes, vim.bo.filetype) then
    vim.b.minuet_virtual_text_auto_trigger = true
  end
end

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
  enable_predicates = {
    ai_completion_allowed,
  },
  virtualtext = {
    auto_trigger_ft = ai_filetypes,
    keymap = {
      -- Blink dispatches shared completion keys to Minuet when AI ghost text is visible.
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
    config = function(_, opts)
      require("minuet").setup(opts)
      require("local.minuet-context").setup()
      enable_current_buffer_auto_trigger()
    end,
  },
}
