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
    if vim.tbl_contains({ "function_definition", "class_definition", "method_definition" }, parent:type()) then
      best = parent
      break
    end
    best = parent
  end
  local start_row, _, end_row = best:range()
  local text = vim.treesitter.get_node_text(best, buf)
  if best:type() == "module" or best:type() == "program" then
    start_row, end_row = math.max(0, row - 8), math.min(vim.api.nvim_buf_line_count(buf), row + 9)
    text = table.concat(vim.api.nvim_buf_get_lines(buf, start_row, end_row, false), "\n")
  end
  if not text or #text > 24000 then
    return nil
  end
  return {
    row = row,
    start_row = start_row,
    end_row = end_row,
    focus = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1],
    text = text,
  }
end

local function viewport(text, offset, width)
  local result, display, index = {}, 0, offset
  local limit = math.max(width - 14, 20)
  while index < vim.fn.strchars(text) and display < limit do
    local char = vim.fn.strcharpart(text, index, 1)
    local char_width = vim.fn.strdisplaywidth(char)
    if display + char_width > limit then
      break
    end
    result[#result + 1], display, index = char, display + char_width, index + 1
  end
  return table.concat(result), index < vim.fn.strchars(text)
end

local function render(buf, entry)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, entry.row, entry.row + 1)
  local text, more = viewport(entry.text, entry.offset, vim.api.nvim_win_get_width(0))
  vim.api.nvim_buf_set_extmark(buf, ns, entry.row, 0, {
    virt_text = {
      { " 󰧑 " .. text .. (entry.streaming and " ▍" or more and " … <C-n>/<C-p>" or ""), "AiExplain" },
    },
    virt_text_pos = "eol",
  })
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
    chat_template_kwargs = { enable_thinking = false },
    messages = {
      {
        role = "system",
        content = "Reply in Simplified Chinese only, as one compact sentence of at most 100 characters. Use exactly this structure: 本行：<this statement's concrete effect>；局部：<its role in the surrounding function or block>；整体：<its role in the nearby workflow>. Never say cursor, line, code, or speculate. No Markdown or code fences.",
      },
      {
        role = "user",
        content = (
          followup
            and ("Code:\n" .. item.context .. "\n\nExisting explanation:\n" .. item.text .. "\n\nQuestion: " .. followup)
          or ("Target statement:\n" .. item.focus .. "\n\nSurrounding context:\n" .. item.context)
        ),
      },
    },
  }
  local partial = ""
  local stderr = {}
  local function publish()
    if s.generation == generation and vim.api.nvim_buf_is_valid(buf) then
      s.entries[item.row] = item
      item.published = true
      render(buf, item)
    end
  end
  local function schedule_publish()
    if item.render_scheduled then
      return
    end
    item.render_scheduled = true
    vim.defer_fn(function()
      item.render_scheduled = nil
      publish()
    end, 60)
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
          and (data.choices[1].delta.content or data.choices[1].delta.reasoning_content)
        if type(token) == "string" then
          item.text = item.text .. token
          schedule_publish()
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
    on_stderr = function(_, data)
      stderr[#stderr + 1] = table.concat(data, "\n")
    end,
    on_exit = function()
      s.jobs[job] = nil
      item.streaming = false
      if s.generation == generation and vim.api.nvim_buf_is_valid(buf) and item.text ~= "" then
        publish()
      elseif s.generation == generation then
        vim.notify("AI explanation request failed: " .. table.concat(stderr, " "), vim.log.levels.WARN)
      end
    end,
  })
  if job <= 0 then
    return
  end
  item.streaming = true
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

local function cancel_jobs(buf)
  local s = state(buf)
  s.generation = s.generation + 1
  for _, job in pairs(s.jobs) do
    pcall(vim.fn.jobstop, job)
  end
  s.jobs = {}
end

function M.page(delta)
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local entry = state(buf).entries[row]
  if not entry then
    return false
  end
  entry.offset = math.max(0, entry.offset + delta * 30)
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
  vim.api.nvim_set_hl(0, "AiExplain", { link = "DiagnosticVirtualTextHint" })
  local group = vim.api.nvim_create_augroup("ai_explain", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function(args)
      cancel_jobs(args.buf)
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
end

return M
