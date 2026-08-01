local M = {}

local DEFAULT_DELAY_MS = 100

local function contains(list, value)
  return vim.tbl_contains(list, value)
end

local function unique(list)
  local seen = {}
  local result = {}
  for _, value in ipairs(list) do
    if not seen[value] then
      seen[value] = true
      table.insert(result, value)
    end
  end
  return result
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

local function prettier_root(path, config_files)
  return vim.fs.root(dirname(path), function(name, root)
    if contains(config_files, name) then
      return true
    end

    return name == "package.json" and package_has_prettier(vim.fs.joinpath(root, name))
  end) or package_root(path)
end

local function warmup_daemon(state, tool, root, file, args)
  local key = table.concat({ tool, root }, "::")
  if state.warmed_daemons[key] then
    return
  end

  local command = vim.fn.exepath(tool)
  if command == "" then
    return
  end
  state.warmed_daemons[key] = true

  local lines = vim.fn.readfile(file)
  vim.system(vim.list_extend({ command }, args), {
    cwd = root,
    stdin = table.concat(lines, "\n"),
    text = true,
  })
end

local function warmup_formatters(state, args)
  if not vim.api.nvim_buf_is_valid(args.buf) then
    return
  end

  local file = vim.api.nvim_buf_get_name(args.buf)
  if file == "" or vim.bo[args.buf].buftype ~= "" then
    return
  end

  local ft = vim.bo[args.buf].filetype

  if contains(state.opts.eslint_d.filetypes, ft) then
    local root = package_root(file)
    if root then
      -- Start eslint_d before the first save so ESLint config and rules are loaded outside the write path.
      warmup_daemon(state, "eslint_d", root, file, { "--fix-to-stdout", "--stdin", "--stdin-filename", file })
    end
  end

  if contains(state.opts.prettierd.filetypes, ft) then
    local root = prettier_root(file, state.opts.prettierd.config_files)
    if root then
      -- Start prettierd before the first save so Prettier config and plugins are loaded outside the write path.
      warmup_daemon(state, "prettierd", root, file, { file })
    end
  end
end

function M.setup(opts)
  opts = vim.tbl_deep_extend("force", {
    delay_ms = DEFAULT_DELAY_MS,
    eslint_d = {
      filetypes = {},
    },
    prettierd = {
      filetypes = {},
      config_files = {},
    },
  }, opts or {})

  local state = {
    opts = opts,
    warmed_daemons = {},
  }

  local patterns = unique(vim.list_extend(vim.deepcopy(opts.eslint_d.filetypes), opts.prettierd.filetypes))
  if #patterns == 0 then
    return
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("formatter_daemon_warmup", { clear = true }),
    pattern = patterns,
    callback = function(args)
      vim.defer_fn(function()
        warmup_formatters(state, args)
      end, opts.delay_ms)
    end,
  })
end

return M
