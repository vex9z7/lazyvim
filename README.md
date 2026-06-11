# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Development

This config keeps local project tooling intentionally small and portable.

- `make format` formats Lua files with StyLua.
- `make lint-format` checks Lua formatting without changing files.
- `make lint` lints Lua files with Selene using Neovim's `vim` standard library.
- `make check` runs formatting checks and linting together.

Install `stylua` and `selene` with your preferred system package manager.
