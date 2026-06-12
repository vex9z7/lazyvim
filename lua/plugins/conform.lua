local js_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

local prettier_filetypes = {
  "css",
  "graphql",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "mdx",
  "typescript",
  "typescriptreact",
}

local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.ts",
  ".prettierrc.cts",
  ".prettierrc.mts",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
  "prettier.config.cts",
  "prettier.config.mts",
}

local warmed_daemons = {}

local function contains(list, value)
  return vim.tbl_contains(list, value)
end

local function dirname(path)
  return vim.fs.dirname(path)
end

local function package_root(path)
  local package_json = vim.fs.find("package.json", { path = dirname(path), upward = true })[1]
  return package_json and dirname(package_json) or nil
end

local function package_has_prettier(package_json)
  local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
  return ok and type(data) == "table" and data.prettier ~= nil
end

local function prettier_root(path)
  return vim.fs.root(dirname(path), function(name, root)
    if contains(prettier_config_files, name) then
      return true
    end

    return name == "package.json" and package_has_prettier(vim.fs.joinpath(root, name))
  end) or package_root(path)
end

local function warmup_daemon(tool, root, file, args)
  local key = table.concat({ tool, root }, "::")
  if warmed_daemons[key] then
    return
  end

  local command = vim.fn.exepath(tool)
  if command == "" then
    return
  end
  warmed_daemons[key] = true

  local lines = vim.fn.readfile(file)
  vim.system(vim.list_extend({ command }, args), {
    cwd = root,
    stdin = table.concat(lines, "\n"),
    text = true,
  })
end

local function warmup_formatter_daemons(args)
  local file = vim.api.nvim_buf_get_name(args.buf)
  if file == "" or vim.bo[args.buf].buftype ~= "" then
    return
  end

  local ft = vim.bo[args.buf].filetype

  if contains(js_filetypes, ft) then
    local root = package_root(file)
    if root then
      -- Start eslint_d before the first save so ESLint config and rules are loaded outside the write path.
      warmup_daemon("eslint_d", root, file, { "--fix-to-stdout", "--stdin", "--stdin-filename", file })
    end
  end

  if contains(prettier_filetypes, ft) then
    local root = prettier_root(file)
    if root then
      -- Start prettierd before the first save so Prettier config and plugins are loaded outside the write path.
      warmup_daemon("prettierd", root, file, { file })
    end
  end
end

return {
  {
    "stevearc/conform.nvim",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("formatter_daemon_warmup", { clear = true }),
        pattern = vim.list_extend(vim.deepcopy(js_filetypes), prettier_filetypes),
        callback = function(args)
          vim.defer_fn(function()
            warmup_formatter_daemons(args)
          end, 100)
        end,
      })
    end,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- Run Ruff lint autofix before Ruff formatting on save.
      -- Requires the Mason-managed Ruff CLI from lua/plugins/mason-tools.lua.
      opts.formatters_by_ft.python = { "ruff_fix", "ruff_format" }

      -- Requires the Mason-managed eslint_d and prettierd CLI formatters from lua/plugins/mason-tools.lua.
      for _, ft in ipairs(js_filetypes) do
        opts.formatters_by_ft[ft] = { "eslint_d", "prettierd" }
      end

      -- Requires the Mason-managed prettierd CLI formatter from lua/plugins/mason-tools.lua.
      for _, ft in ipairs(prettier_filetypes) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or { "prettierd" }
      end
    end,
  },
}
