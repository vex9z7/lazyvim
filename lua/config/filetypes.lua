-- Keep filetype detection explicit for formats that Neovim may not recognize
-- consistently across versions or minimal environments.
vim.filetype.add {
  extension = {
    -- MDX is Markdown with embedded JSX; use the dedicated filetype so
    -- formatter/LSP/plugin rules can target it without extra detection plugins.
    mdx = "mdx",
  },
}
