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

## Interactive Python

Python files support `# %%` cells through NotebookNavigator and execute them in
a Jupyter kernel through Molten. Results are shown as virtual lines instead of a
terminal split.

This integration has two separate external Python dependencies:

1. A machine-wide Neovim Python host lets Molten communicate with Jupyter.
2. A project environment provides the kernel that runs the project's code.

### Neovim Python host (once per machine)

The config expects an isolated host at:

```text
~/.local/share/nvim/python/bin/python
```

Create it with a Python selected by your preferred version manager, then install
Molten's host dependencies:

```sh
python -m venv ~/.local/share/nvim/python
~/.local/share/nvim/python/bin/python -m pip install pynvim jupyter_client
mkdir -p "$(~/.local/share/nvim/python/bin/jupyter --runtime-dir)"
```

When a Python file is opened, Neovim warns if this interpreter or its `pynvim`
and `jupyter_client` packages are missing. It does not install them automatically.

### Project kernel (once per project environment)

Activate the project's environment first. It needs `ipykernel`; this is the
environment in which project code and imports run:

```sh
python -m pip install ipykernel
```

When a cell is executed, Neovim offers to install `ipykernel` and register its
kernelspec as one confirmed operation if the selected environment does not
already provide it.

Select the environment with `<leader>cv`, then execute a cell with `<leader>je`.
The first execution reuses a kernelspec that points to the selected environment.
If none exists, Neovim asks before registering one. Package installation and
kernel registration always require confirmation. Later executions reuse the
running kernel.

Selecting a different environment with `<leader>cv` stops a kernel that belongs
to the previous environment. The new kernel starts lazily on the next
`<leader>je` or `<leader>jE`; merely selecting an environment never starts a
kernel or installs anything.

Confirm that the registered kernel points to the intended project interpreter:

```sh
~/.local/share/nvim/python/bin/jupyter kernelspec list
```

Virtual output shows at most 12 lines below a cell. Use `<leader>jo` with the
cursor in an evaluated cell to open its complete output in a normal, scrollable
100×20 floating window. Press `q` or `<Esc>` to close it. It reports a harmless
message instead of starting a kernel when no output is available.

Use `<leader>jy` with the cursor in an evaluated cell to copy its output. With
Neovim's clipboard provider, it copies to the system clipboard as well as the
unnamed register.

Use `<leader>jE` to execute the current cell and every cell above it, `[j` / `]j`
to navigate between cells, `<leader>jr` to restart the kernel and clear its
outputs, and `<leader>jx` to interrupt it.
