-- Small adapter used by blink.cmp keymaps. Blink owns the insert-mode
-- completion keys; this module only gives Minuet virtual text the first chance
-- to handle accept/dismiss/next/prev when AI ghost text is active.
local M = {}

local function virtualtext()
  local ok, vt = pcall(require, "minuet.virtualtext")
  if ok then
    return vt
  end
end

local function is_active(vt)
  if type(vt.action.is_active) == "function" then
    return vt.action.is_active()
  end

  return vt.action.is_visible()
end

local function has_suggestion(vt)
  if type(vt.action.has_suggestion) == "function" then
    return vt.action.has_suggestion()
  end

  return vt.action.is_visible()
end

local function run(action)
  local vt = virtualtext()
  if not vt or not is_active(vt) then
    return false
  end

  -- Minuet can be active while only a pending/status line is visible. Treat an
  -- accept attempt during that state as handled so it does not accept a Blink
  -- item by accident.
  if action == "accept" and not has_suggestion(vt) then
    return true
  end

  vt.action[action]()
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
