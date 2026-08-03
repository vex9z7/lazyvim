local M = {}

local keys = {
  ["<C-y>"] = { minuet = "accept", blink = "select_and_accept" },
  ["<C-e>"] = { minuet = "dismiss", blink = "cancel" },
  ["<C-n>"] = { minuet = "next", blink = "select_next" },
  ["<C-p>"] = { minuet = "prev", blink = "select_prev" },
}

local function feed_fallback(key)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "n", false)
end

local function minuet_is_active(virtualtext)
  if type(virtualtext.action.is_active) == "function" then
    return virtualtext.action.is_active()
  end

  return virtualtext.action.is_visible()
end

local function minuet_has_suggestion(virtualtext)
  if type(virtualtext.action.has_suggestion) == "function" then
    return virtualtext.action.has_suggestion()
  end

  return virtualtext.action.is_visible()
end

local function run_minuet(action)
  local ok, virtualtext = pcall(require, "minuet.virtualtext")
  if not ok or not minuet_is_active(virtualtext) then
    return false
  end

  -- Some Minuet forks expose a pending/status-only state before candidate text
  -- exists. Accept only when the active virtual text contains a real suggestion.
  if action == "accept" and not minuet_has_suggestion(virtualtext) then
    return true
  end

  virtualtext.action[action]()
  return true
end

local function run_blink(action)
  local ok, blink = pcall(require, "blink.cmp")
  if not ok or type(blink[action]) ~= "function" then
    return false
  end

  return blink[action]() == true
end

local function should_skip_buffer(bufnr)
  local buftype = vim.bo[bufnr].buftype
  if buftype == "prompt" or buftype == "terminal" then
    return true
  end

  local filetype = vim.bo[bufnr].filetype
  return filetype:match "^snacks_picker" ~= nil
end

local function clear_ai_key(bufnr, key)
  for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(bufnr, "i")) do
    if mapping.lhs == key and mapping.desc and mapping.desc:match "^AI%-aware completion" then
      pcall(vim.keymap.del, "i", key, { buffer = bufnr })
      return
    end
  end
end

local function map_key(bufnr, key, actions)
  vim.keymap.set("i", key, function()
    if run_minuet(actions.minuet) or run_blink(actions.blink) then
      return
    end

    feed_fallback(key)
  end, {
    buffer = bufnr,
    desc = "AI-aware completion " .. actions.minuet,
    silent = true,
  })
end

function M.apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if should_skip_buffer(bufnr) then
    for key in pairs(keys) do
      clear_ai_key(bufnr, key)
    end
    return
  end

  for key, actions in pairs(keys) do
    map_key(bufnr, key, actions)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("LocalAiCompletionKeys", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
    group = group,
    callback = function(event)
      -- Blink uses buffer-local mappings too. Schedule our mappings so they win
      -- after Blink has had a chance to apply its own completion keymaps.
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(event.buf) then
          M.apply(event.buf)
        end
      end)
    end,
  })

  M.apply()
end

return M
