# Codebook Spell Playground

This playground is for manually validating `codebook-lsp`.

Expected route:

- Codebook runs as a normal LSP server through nvim-lspconfig.
- Diagnostics and dictionary actions should use the normal LSP UI.
- `codebook.toml` provides project-local allowlisted words.

## Manual checks

Open `sample.md` or `sample.py` and confirm diagnostics appear for words such as
`sentense`, `recieve`, and `Vexnvim`.

Use the normal code-action UI:

```vim
<leader>ca
```

Expected actions should include suggestions and an option to add an unknown word
to the dictionary.

Use Trouble to list diagnostics:

```vim
<leader>xX
```

Reset after experimenting:

```bash
git checkout -- codebook.toml sample.md sample.py
```
