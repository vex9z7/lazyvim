-- Disable LazyVim's default nvim-lint plugin; diagnostics/code actions come from LSP, and save-time fixes run through conform.
return {
  { "mfussenegger/nvim-lint", enabled = false },
}
