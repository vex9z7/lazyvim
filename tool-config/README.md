# Tool Config

This directory stores portable fallback configuration for external tools used by
this Neovim config.

Project-local configuration still wins when a repository provides it. Files here
are for personal defaults and dictionaries that should travel with the Neovim
config instead of living only in machine-local dotfiles.

Currently configured:

- `codebook/codebook.toml`: global Codebook fallback dictionary, passed to
  `codebook-lsp` with `globalConfigPath`.
