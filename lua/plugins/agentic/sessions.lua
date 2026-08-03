local M = {}

local function session_label(session_info)
  local updated_at = session_info.updatedAt and session_info.updatedAt:sub(1, 16):gsub("T", " ") or "unknown date"
  local title = session_info.title or "(no title)"

  return string.format("%s - %s", updated_at, title), updated_at, title
end

function M.pick()
  local agentic = require "agentic"
  local SessionRegistry = require "agentic.session_registry"

  SessionRegistry.get_session_for_tab_page(nil, function(session)
    session.agent:when_ready(function()
      session.agent:list_sessions(vim.fn.getcwd(), function(result, err)
        local items = {
          {
            label = "New session",
            run = function()
              agentic.new_session()
            end,
          },
        }

        if err then
          vim.notify("Failed to list Agentic sessions: " .. (err.message or "unknown error"), vim.log.levels.WARN)
        end

        for _, session_info in ipairs((result and result.sessions) or {}) do
          local label, updated_at, title = session_label(session_info)
          local session_id = session_info.sessionId
          items[#items + 1] = {
            label = label,
            run = function()
              session:load_acp_session(session_id, title, updated_at)
              session.widget:show()
            end,
          }
        end

        vim.schedule(function()
          vim.ui.select(items, {
            prompt = "Agentic Sessions",
            format_item = function(item)
              return item.label
            end,
          }, function(item)
            if item and item.run then
              item.run()
            end
          end)
        end)
      end)
    end)
  end)
end

return M
