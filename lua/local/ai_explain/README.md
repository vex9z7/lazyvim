# Local AI Explain

A private, local trial for cursor-driven code explanations and concise `Nudge`
diagnostics. It is deliberately **not** packaged as a Neovim plugin yet.

## Host configuration

The host config owns the endpoint, model, API-key environment variable, language,
and keymaps:

```lua
require("local.ai_explain").setup {
  endpoint = "https://…/v1/chat/completions",
  model = "…",
  api_key_env = "LLAMACPP_API_KEY",
  language = "en",
  languages = {
    en = { name = "English", max_characters = 100, example = "…" },
  },
}
```

The endpoint must implement streaming OpenAI-compatible chat completions. The
module uses the system `curl`; the API key is read from the named environment
variable and falls back to `local` when no key is required.

## Current behavior

- After the cursor is idle on a meaningful Tree-sitter node, stream one
  explanation below the active line.
- Keep a single lightbulb marker on previously explained lines.
- Ignore blank, comment, and syntax-only lines.
- For errors and meaningful warnings, request a short `Nudge` diagnostic before
  requesting the explanation.
- Invalidate explanations affected by edits while retaining unrelated ones.
- `<leader>K` is host-owned and asks a follow-up about the current explanation.

## Before publishing

Keep this module local until its transport and interaction model are stable.
Publishing should add plugin metadata, documented defaults, and tests then—not a
second implementation now.
