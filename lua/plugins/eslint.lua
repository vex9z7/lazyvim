-- Keep save-time ESLint fixes in conform so the ESLint LSP only provides
-- diagnostics and interactive code actions.
vim.g.lazyvim_eslint_auto_format = false

return {
  { import = "lazyvim.plugins.extras.linting.eslint" },
}
