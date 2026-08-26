-- Native Neovim Lua counterpart to clang/tools/clang-format/clang-format.py.
-- It deliberately preserves clang-format's defaults, including include sorting.
local M = {}

local function project_root(path)
  local marker = vim.fs.find(".git", { path = vim.fs.dirname(path), upward = true, limit = 1 })[1]
  return marker and vim.fs.dirname(marker) or nil
end

function M.is_llama_cpp(path)
  local root = project_root(path)
  return root ~= nil and vim.fs.basename(root) == "llama.cpp"
end

local function text_from_lines(lines)
  return table.concat(lines, "\n") .. "\n"
end

local function changed_ranges(ondisk, current)
  local ranges = {}
  -- vim.diff is Neovim's native counterpart to the Python script's
  -- difflib.SequenceMatcher. Like the original, deletion-only hunks have no
  -- current-buffer range and are skipped.
  for _, hunk in ipairs(vim.diff(ondisk, current, { result_type = "indices" })) do
    local start, count = hunk[3], hunk[4]
    if count > 0 then
      table.insert(ranges, { start, start + count - 1 })
    end
  end
  return ranges
end

local function cursor_byte(lines, bufnr)
  local line, column = 1, 1
  if bufnr and bufnr == vim.api.nvim_get_current_buf() then
    line, column = unpack(vim.api.nvim_win_get_cursor(0))
    column = column + 1
  end

  local offset = 0
  for index = 1, line - 1 do
    offset = offset + #(lines[index] or "") + 1
  end
  return offset + column - 1
end

local function cursor_position(text, offset)
  local prefix = text:sub(1, offset)
  local line = 1 + select(2, prefix:gsub("\n", "\n"))
  local column = #prefix:match "[^\n]*$" + 1
  return line, column
end

local function clang_format_command()
  local binary = vim.g.clang_format_path or "clang-format"
  local executable = vim.fn.exepath(binary)
  if executable == "" then
    return nil, ("clang-format is not executable: %s"):format(binary)
  end
  return executable
end

local function line_arguments(filename, current, opts)
  if opts.lines then
    return { "--lines", opts.lines }
  end

  if opts.formatdiff then
    local file = io.open(filename, "rb")
    if file then
      local ranges = changed_ranges(file:read "*a", current)
      file:close()
      if #ranges == 0 then
        return false
      end

      local arguments = {}
      for index = #ranges, 1, -1 do
        local range = ranges[index]
        vim.list_extend(arguments, { "--lines", ("%d:%d"):format(range[1], range[2]) })
      end
      return arguments
    end
  end

  local range = opts.range or { 1, 1 }
  return { "--lines", ("%d:%d"):format(range[1], range[2]) }
end

-- Format lines without modifying a buffer. This is independent of Conform; a
-- caller chooses when to invoke it and receives formatted lines through the
-- callback. opts supports lines, formatdiff, range, and bufnr.
function M.format(filename, lines, opts, callback)
  if type(opts) == "function" then
    callback = opts
    opts = { formatdiff = true }
  end
  opts = opts or {}

  local current = text_from_lines(lines)
  local line_args, err = line_arguments(filename, current, opts)
  if err then
    callback(err)
    return
  end
  if line_args == false then
    callback(nil, lines)
    return
  end

  local clang_format, command_err = clang_format_command()
  if not clang_format then
    callback(command_err)
    return
  end

  local command = { clang_format, "--cursor", tostring(cursor_byte(lines, opts.bufnr)) }
  if not (#line_args == 2 and line_args[2] == "all") then
    vim.list_extend(command, line_args)
  end
  if vim.g.clang_format_fallback_style then
    vim.list_extend(command, { "--fallback-style", vim.g.clang_format_fallback_style })
  end
  vim.list_extend(command, { "--assume-filename", filename })

  vim.system(command, { cwd = vim.fs.dirname(filename), stdin = current, text = true }, function(result)
    vim.schedule(function()
      if result.stderr ~= "" then
        vim.notify(result.stderr, vim.log.levels.WARN)
      end
      if result.stdout == "" then
        callback(result.stderr ~= "" and result.stderr or "clang-format failed")
        return
      end

      local header, content = result.stdout:match "^([^\n]*)\n(.*)$"
      local ok, metadata = false, nil
      if header then
        ok, metadata = pcall(vim.json.decode, header)
      end
      if not ok then
        callback "clang-format returned invalid cursor metadata"
        return
      end
      if metadata.IncompleteFormat then
        vim.notify("clang-format: incomplete (syntax errors)", vim.log.levels.WARN)
      end

      local output = vim.split(content, "\n", { plain = true })
      if content:sub(-1) == "\n" then
        table.remove(output)
      end
      callback(nil, output, metadata)
    end)
  end)
end

-- Apply the same result to a buffer using reverse-order minimal edits, as the
-- Python integration does. opts has the same fields as format().
function M.format_buffer(opts, callback)
  opts = opts or {}
  callback = callback or function() end
  local bufnr = opts.bufnr or 0
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    callback "clang-format requires a named buffer"
    return
  end

  local input = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  opts.bufnr = bufnr
  if not opts.lines and not opts.formatdiff and not opts.range then
    local line = bufnr == vim.api.nvim_get_current_buf() and vim.api.nvim_win_get_cursor(0)[1] or 1
    opts.range = { line, line }
  end
  M.format(filename, input, opts, function(err, output, metadata)
    if err or not output then
      callback(err)
      return
    end

    local edits = vim.diff(text_from_lines(input), text_from_lines(output), { result_type = "indices" })
    for index = #edits, 1, -1 do
      local hunk = edits[index]
      local replacement = {}
      for line = hunk[3], hunk[3] + hunk[4] - 1 do
        table.insert(replacement, output[line])
      end
      vim.api.nvim_buf_set_lines(bufnr, hunk[1] - 1, hunk[1] - 1 + hunk[2], false, replacement)
    end

    if metadata and metadata.Cursor and bufnr == vim.api.nvim_get_current_buf() then
      vim.api.nvim_win_set_cursor(0, { cursor_position(text_from_lines(output), metadata.Cursor) })
    end
    callback(nil)
  end)
end

-- Convenience entry point for a normal- or Visual-mode mapping. Explicit
-- ranges still use format_buffer({ range = { start_line, end_line } }).
function M.format_current(callback)
  local opts = {}
  if vim.fn.mode():find "^[vV\22]" then
    opts.range = { vim.fn.line "'<", vim.fn.line "'>" }
  end
  M.format_buffer(opts, callback)
end

return M
