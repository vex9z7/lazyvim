-- Config-local Minuet adapter, not upstream Minuet code. Override Minuet's
-- context builder so automatic inline completion sends only cursor-near
-- prefix/suffix text instead of reading or serializing the whole buffer.
local M = {}

local function char_count(text)
  return vim.fn.strchars(text or "")
end

local function take_prefix(text, limit)
  if limit <= 0 then
    return "", text ~= ""
  end

  local length = char_count(text)
  if length <= limit then
    return text, false
  end

  return vim.fn.strcharpart(text, 0, limit), true
end

local function take_suffix(text, limit)
  if limit <= 0 then
    return "", text ~= ""
  end

  local length = char_count(text)
  if length <= limit then
    return text, false
  end

  return vim.fn.strcharpart(text, length - limit), true
end

local function add_before(parts, text, remaining)
  local piece, truncated = take_suffix(text, remaining)
  if piece ~= "" then
    table.insert(parts, 1, piece)
  end

  return remaining - char_count(piece), truncated
end

local function add_after(parts, text, remaining)
  local piece, truncated = take_prefix(text, remaining)
  if piece ~= "" then
    table.insert(parts, piece)
  end

  return remaining - char_count(piece), truncated
end

local function local_context(cmp_context)
  local config = require("minuet").config
  local cursor = cmp_context.cursor
  local context_window = config.context_window
  local before_budget = math.floor(context_window * config.context_ratio)
  local after_budget = context_window - before_budget
  local bufnr = vim.api.nvim_get_current_buf()

  local before_parts = {}
  local after_parts = {}
  local before_truncated = false
  local after_truncated = false

  before_budget, before_truncated = add_before(before_parts, cmp_context.cursor_before_line or "", before_budget)
  for row = cursor.line - 1, 0, -1 do
    if before_budget <= 0 then
      before_truncated = true
      break
    end

    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local truncated
    before_budget, truncated = add_before(before_parts, line .. "\n", before_budget)
    before_truncated = before_truncated or truncated
  end

  if before_budget <= 0 and cursor.line > 0 then
    before_truncated = true
  end

  after_budget, after_truncated = add_after(after_parts, cmp_context.cursor_after_line or "", after_budget)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for row = cursor.line + 1, line_count - 1 do
    if after_budget <= 0 then
      after_truncated = true
      break
    end

    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local truncated
    after_budget, truncated = add_after(after_parts, "\n" .. line, after_budget)
    after_truncated = after_truncated or truncated
  end

  if after_budget <= 0 and cursor.line < line_count - 1 then
    after_truncated = true
  end

  return {
    lines_before = table.concat(before_parts, ""),
    lines_after = table.concat(after_parts, ""),
    opts = {
      is_incomplete_before = before_truncated,
      is_incomplete_after = after_truncated,
    },
  }
end

function M.setup()
  local utils = require "minuet.utils"
  utils.get_context = local_context
end

return M
