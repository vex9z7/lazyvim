-- Config-local adapter for the pinned Minuet fork. Blink's completion menu
-- always owns shared completion keys; Minuet handles them only otherwise.
local M = {}

local function action()
  return require("minuet.virtualtext").action
end

local function run(name)
  local minuet = action()
  if require("blink.cmp").is_menu_visible() then
    return false
  end

  if not minuet.is_active() then
    return false
  end

  -- Do not consume Ctrl-y while Minuet is still generating a suggestion.
  if name == "accept" and not minuet.has_suggestion() then
    return false
  end

  minuet[name]()
  return true
end

function M.accept()
  return run "accept"
end

function M.dismiss()
  return run "dismiss"
end

function M.next()
  return run "next"
end

function M.prev()
  return run "prev"
end

return M
