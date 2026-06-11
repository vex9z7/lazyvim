# Neovim Playgrounds

These files are manual playgrounds for validating and trying editing behavior in
this LazyVim config. They are not automated tests or benchmarks.

Use them when changing editor plugins or options that affect interactive editing,
visual feedback, or language-specific behavior. It is fine to edit these files
while experimenting; reset them with Git when they get messy.

## Current playgrounds

- `surround.html`, `surround.jsx`, and `surround.tsx`: try surround editing,
  especially tag add/delete/change behavior in HTML, JSX, and TSX.
- `highlight-colors.css` and `highlight-colors.jsx`: try inline color previews
  for hex, RGB, HSL, CSS variables, Tailwind classes, and arbitrary Tailwind
  color values.
- `markdown.md`: try rendered Markdown display and the `<leader>um` toggle.
