local M = {}

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

local function dirname(path)
  return vim.fs.dirname(path)
end

local function package_root(file)
  local package_json = vim.fs.find("package.json", { path = dirname(file), upward = true })[1]
  return package_json and dirname(package_json) or nil
end

local function package_has_prettier(package_json)
  local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
  return ok and type(data) == "table" and data.prettier ~= nil
end

local function prettier_root(file)
  return vim.fs.root(dirname(file), function(name, root)
    if vim.tbl_contains(prettier_config_files, name) then
      return true
    end

    return name == "package.json" and package_has_prettier(vim.fs.joinpath(root, name))
  end) or package_root(file)
end

function M.daemons()
  return {
    {
      name = "eslint_d",
      filetypes = js_filetypes,
      root = package_root,
      args = function(file)
        return { "--fix-to-stdout", "--stdin", "--stdin-filename", file }
      end,
    },
    {
      name = "prettierd",
      filetypes = prettier_filetypes,
      root = prettier_root,
      args = function(file)
        return { file }
      end,
    },
  }
end

return M
