# ESLint Linter Playground

This playground is for manually validating ESLint diagnostics, code actions, and
save-time autofix behavior in Neovim.

## Setup

Install the playground-local ESLint dependency once:

```bash
cd playgrounds/linter-eslint
npm install
```

The ESLint LSP expects a project-local `eslint` package. `eslint_d` can fall back
to its bundled ESLint for some CLI use, but diagnostics and code actions should
be validated with the local dependency installed.

## Manual checks

Open `sample.js` in Neovim and confirm:

- ESLint diagnostics appear for `var`, double quotes, and missing semicolons.
- Code actions are available through the normal LSP code-action UI.
- Saving the file runs conform's `eslint_d` + `prettierd` chain and fixes the
  sample.

Reset the sample after experimenting:

```bash
git checkout -- sample.js
```
