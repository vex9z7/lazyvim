# Python Linter Playground

This playground is for manually validating Python diagnostics, code actions, and
save-time formatting in Neovim.

Expected route:

- Pyright provides Python language intelligence.
- Ruff LSP provides lint diagnostics and code actions through LazyVim's Python Extra.
- conform runs Ruff on save: `ruff_fix` for lint autofix, then `ruff_format` for formatting.

Open `sample.py` and confirm Ruff diagnostics appear for import order, unused
imports or variables, and formatting issues. Saving the file should apply Ruff
lint fixes first and Ruff formatting second.

Reset the sample after experimenting:

```bash
git checkout -- sample.py
```
