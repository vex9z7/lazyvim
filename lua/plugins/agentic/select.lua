local M = {}

function M.pick(items, prompt)
  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(item)
      return item.label
    end,
  }, function(item)
    if item and item.run then
      item.run()
    end
  end)
end

return M
