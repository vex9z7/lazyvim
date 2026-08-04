local M = {}

local ns = vim.api.nvim_create_namespace "ai_explain"
local buffers = {}
local ignored_buftypes = { help = true, prompt = true, quickfix = true, terminal = true }
local ignored_paths = { "/%.env", "/%.ssh/", "/%.gnupg/", "/secret", "/credential", "%.pem$", "%.key$" }

local function allowed(buf)
  if ignored_buftypes[vim.bo[buf].buftype] or not vim.bo[buf].modifiable or vim.bo[buf].filetype == "" then
    return false
  end
  local path = vim.api.nvim_buf_get_name(buf):lower()
  return not vim.tbl_contains(ignored_paths, path)
    and not vim.iter(ignored_paths):any(function(pattern)
      return path:find(pattern) ~= nil
    end)
end

local function state(buf)
  if not buffers[buf] then
    buffers[buf] = { generation = 0, entries = {}, jobs = {} }
  end
  return buffers[buf]
end

local function context(buf, row, col)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { row, col } })
  if not ok or not node or node:has_error() then
    return nil
  end
  local best = node
  while best:parent() do
    local parent = best:parent()
    local start_row, _, end_row = parent:range()
    if end_row - start_row > 120 then
      break
    end
    best = parent
  end
  local start_row, _, end_row = best:range()
  local text = vim.treesitter.get_node_text(best, buf)
  if not text or #text > 24000 then
    return nil
  end
  return { row = row, start_row = start_row, end_row = end_row, text = text }
end

local function wrap(text, width)
  local lines, limit = {}, math.max(width - 8, 30)
  for line in text:gmatch "[^\n]+" do
    while vim.fn.strdisplaywidth(line) > limit do
      local cut = limit
      while cut > 1 and vim.fn.strdisplaywidth(line:sub(1, cut)) > limit do
        cut = cut - 1
      end
      lines[#lines + 1], line = line:sub(1, cut), line:sub(cut + 1)
    end
    lines[#lines + 1] = line
  end
  return lines
end

local function render(buf, entry)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, entry.row, entry.row + 1)
  local current = vim.api.nvim_get_current_buf() == buf and vim.api.nvim_win_get_cursor(0)[1] - 1 == entry.row
  local lines = wrap(entry.text, vim.api.nvim_win_get_width(0))
  if current then
    local from = entry.offset + 1
    local virtual = {}
    for i = from, math.min(from + 4, #lines) do
      virtual[#virtual + 1] = { { "󰧑 " .. lines[i], "Comment" } }
    end
    if #lines > from + 4 then
      virtual[#virtual + 1] = { { "…  <C-n>/<C-p>", "Comment" } }
    end
    vim.api.nvim_buf_set_extmark(buf, ns, entry.row, 0, { virt_lines = virtual, virt_lines_above = false })
  else
    vim.api.nvim_buf_set_extmark(
      buf,
      ns,
      entry.row,
      0,
      { virt_text = { { " 󰧑 " .. (lines[1] or "Explanation"), "Comment" } }, virt_text_pos = "eol" }
    )
  end
end

local function render_all(buf)
  local s = state(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, entry in pairs(s.entries) do
    render(buf, entry)
  end
end

local function clear(buf)
  local s = state(buf)
  s.generation = s.generation + 1
  for _, job in pairs(s.jobs) do
    pcall(vim.fn.jobstop, job)
  end
  s.entries, s.jobs = {}, {}
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

local function request(buf, item, followup)
  local s, generation = state(buf), state(buf).generation
  local payload = {
    model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF/UD-Q4_K_M",
    stream = true,
    max_tokens = 350,
    messages = {
      {
        role = "system",
        content = "Explain the supplied code concisely in plain language. Do not use markdown headings or code fences. Do not speculate.",
      },
      {
        role = "user",
        content = (
          followup
            and ("Code:\n" .. item.context .. "\n\nExisting explanation:\n" .. item.text .. "\n\nQuestion: " .. followup)
          or ("Code:\n" .. item.context)
        ),
      },
    },
  }
  local partial = ""
  local function publish()
    if s.generation == generation and vim.api.nvim_buf_is_valid(buf) then
      s.entries[item.row] = item
      item.published = true
      render(buf, item)
    end
  end
  local function consume(chunk)
    partial = partial .. chunk
    for line in partial:gmatch "(.-)\n" do
      if line:sub(1, 6) == "data: " then
        local ok, data = pcall(vim.json.decode, line:sub(7))
        local token = ok
          and data.choices
          and data.choices[1]
          and data.choices[1].delta
          and data.choices[1].delta.content
        if token then
          item.text = item.text .. token
          if not item.published and #wrap(item.text, vim.api.nvim_win_get_width(0)) >= 5 then
            publish()
          end
        end
      end
    end
    partial = partial:match "[^\n]*$" or ""
  end
  local job
  job = vim.fn.jobstart({
    "curl",
    "--no-buffer",
    "--silent",
    "--show-error",
    "-X",
    "POST",
    "https://llamacpp-stack.vex9z7.com/v1/chat/completions",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. (vim.env.LLAMACPP_API_KEY or "local"),
    "-d",
    vim.json.encode(payload),
  }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      consume(table.concat(data, "\n"))
    end,
    on_exit = function()
      s.jobs[job] = nil
      if s.generation == generation and vim.api.nvim_buf_is_valid(buf) and item.text ~= "" then
        publish()
      end
    end,
  })
  if job <= 0 then
    return
  end
  s.jobs[job] = job
end

function M.explain()
  local buf = vim.api.nvim_get_current_buf()
  if vim.fn.mode() ~= "n" or not allowed(buf) then
    return
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local s = state(buf)
  if s.entries[row] or next(s.jobs) then
    return
  end
  local item = context(buf, row, col)
  if not item then
    return
  end
  item.context, item.text, item.offset = item.text, "", 0
  request(buf, item)
end

function M.page(delta)
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local entry = state(buf).entries[row]
  if not entry then
    return false
  end
  entry.offset = math.max(0, entry.offset + delta * 5)
  render(buf, entry)
  return true
end

function M.followup()
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local entry = state(buf).entries[row]
  if not entry then
    vim.notify("No code explanation on this line", vim.log.levels.INFO)
    return
  end
  vim.ui.input({ prompt = "Ask about this explanation: " }, function(answer)
    if answer and answer ~= "" then
      entry.text = ""
      request(buf, entry, answer)
    end
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ai_explain", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function(args)
      render_all(args.buf)
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_get_current_buf() == args.buf then
          M.explain()
        end
      end, 1200)
    end,
  })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function(args)
      clear(args.buf)
    end,
  })
  vim.keymap.set("n", "<C-n>", function()
    return M.page(1) and "" or "<C-n>"
  end, { expr = true, desc = "Next explanation page" })
  vim.keymap.set("n", "<C-p>", function()
    return M.page(-1) and "" or "<C-p>"
  end, { expr = true, desc = "Previous explanation page" })
  vim.keymap.set("n", "<leader>K", M.followup, { desc = "Ask about code explanation" })
end

return M
