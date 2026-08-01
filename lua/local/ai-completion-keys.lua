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

local function run_minuet(action)
  local ok, virtualtext = pcall(require, "minuet.virtualtext")
  if not ok or not virtualtext.action.is_visible() then
    return false
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
