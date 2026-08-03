-- Config-local adapter for the pinned Minuet fork. Blink owns the insert-mode
-- completion keys; Minuet gets first chance only when AI virtual text is pending
-- or shown.
local M = {}

local function action()
  return require("minuet.virtualtext").action
end

local function run(name)
  local minuet = action()
  if not minuet.is_active() then
    return false
  end

  -- When only the pending/status line is visible, consume accept so Blink does
  -- not accept a completion item before Minuet has produced text.
  if name == "accept" and not minuet.has_suggestion() then
    return true
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
