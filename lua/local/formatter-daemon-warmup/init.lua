local M = {}

local defaults = require "local.formatter-daemon-warmup.defaults"

local DEFAULT_DELAY_MS = 100

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

local function default_stdin(file)
  return table.concat(vim.fn.readfile(file), "\n")
end

local function log(state, message)
  if not state.opts.debug then
    return
  end

  state.opts.log(message)
end

local function daemon_supports_filetype(daemon, filetype)
  return vim.tbl_contains(daemon.filetypes or {}, filetype)
end

local function warmup_daemon(state, daemon, file, bufnr)
  if daemon.enabled == false then
    return
  end

  local command = vim.fn.exepath(daemon.command or daemon.name)
  if command == "" then
    log(state, string.format("skip %s: command not found", daemon.name))
    return
  end

  if daemon.condition and not daemon.condition(file, bufnr) then
    log(state, string.format("skip %s: condition failed", daemon.name))
    return
  end

  local root = daemon.root and daemon.root(file, bufnr) or vim.fs.dirname(file)
  if not root then
    log(state, string.format("skip %s: root not found", daemon.name))
    return
  end

  local key = table.concat({ daemon.name, root }, "::")
  if state.warmed_daemons[key] then
    log(state, string.format("skip %s: already warmed for %s", daemon.name, root))
    return
  end
  state.warmed_daemons[key] = true

  local args = daemon.args and daemon.args(file, bufnr, root) or {}
  local stdin = daemon.stdin and daemon.stdin(file, bufnr, root) or default_stdin(file)

  log(state, string.format("warm %s cwd=%s", daemon.name, root))
  vim.system(vim.list_extend({ command }, args), {
    cwd = root,
    stdin = stdin,
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

  local filetype = vim.bo[args.buf].filetype
  for _, daemon in ipairs(state.opts.daemons) do
    if daemon_supports_filetype(daemon, filetype) then
      warmup_daemon(state, daemon, file, args.buf)
    end
  end
end

function M.setup(opts)
  opts = opts or {}
  local daemons = opts.daemons or defaults.daemons()

  opts = vim.tbl_deep_extend("force", {
    debug = false,
    delay_ms = DEFAULT_DELAY_MS,
    log = function(message)
      vim.notify(message, vim.log.levels.DEBUG, { title = "formatter-daemon-warmup" })
    end,
  }, opts)
  opts.daemons = daemons

  local patterns = {}
  for _, daemon in ipairs(opts.daemons) do
    vim.list_extend(patterns, daemon.filetypes or {})
  end
  patterns = unique(patterns)
  if #patterns == 0 then
    return
  end

  local state = {
    opts = opts,
    warmed_daemons = {},
  }

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
