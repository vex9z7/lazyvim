local M = {}

local function project_root(path)
  local marker = vim.fs.find(".git", { path = vim.fs.dirname(path), upward = true, limit = 1 })[1]
  return marker and vim.fs.dirname(marker) or nil
end

function M.is_llama_cpp(path)
  local root = project_root(path)
  return root ~= nil and vim.fs.basename(root) == "llama.cpp"
end

local function changed_ranges(ondisk, current)
  local ranges = {}
  for _, hunk in ipairs(vim.diff(ondisk, current, { algorithm = "histogram", result_type = "indices" })) do
    local start, count = hunk[3], hunk[4]
    if count > 0 then
      table.insert(ranges, { start, start + count - 1 })
    end
  end
  return ranges
end

function M.format(filename, lines, callback)
  local file, err = io.open(filename, "rb")
  if not file then
    callback(err)
    return
  end
  local ondisk = file:read "*a"
  file:close()

  local current = table.concat(lines, "\n") .. "\n"
  local ranges = changed_ranges(ondisk, current)
  if #ranges == 0 then
    callback(nil, lines)
    return
  end

  local clang_format = vim.fn.exepath "clang-format"
  if clang_format == "" then
    callback "clang-format is not executable"
    return
  end

  local command = { clang_format, "--assume-filename", filename }
  for _, range in ipairs(ranges) do
    vim.list_extend(command, { "--lines", ("%d:%d"):format(range[1], range[2]) })
  end

  vim.system(command, { cwd = vim.fs.dirname(filename), stdin = current, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        callback(result.stderr ~= "" and result.stderr or "clang-format failed")
        return
      end

      local output = vim.split(result.stdout, "\n", { plain = true })
      if result.stdout:sub(-1) == "\n" then
        table.remove(output)
      end
      callback(nil, output)
    end)
  end)
end

return M
