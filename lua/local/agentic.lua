local M = {}

local function session_label(session_info)
  local updated_at = session_info.updatedAt and session_info.updatedAt:sub(1, 16):gsub("T", " ") or "unknown date"
  local title = session_info.title or "(no title)"

  return string.format("%s - %s", updated_at, title), updated_at, title
end

local function new_session_item(agentic)
  return {
    idx = 1,
    text = "New session",
    run = function()
      agentic.new_session()
    end,
  }
end

local function restore_session_item(index, session, session_info)
  local text, updated_at, title = session_label(session_info)
  local session_id = session_info.sessionId

  return {
    idx = index,
    text = text,
    run = function()
      session:load_acp_session(session_id, title, updated_at)
      session.widget:show()
    end,
  }
end

local function pick_items(items)
  Snacks.picker.pick {
    source = "agentic_sessions",
    title = "Agentic Sessions",
    finder = function()
      return items
    end,
    format = "text",
    preview = "none",
    layout = {
      reverse = true,
      layout = {
        box = "vertical",
        backdrop = false,
        width = 0.96,
        height = 0.7,
        border = "none",
        { win = "list", title = " Sessions ", title_pos = "center", border = true },
        { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
      },
    },
    main = {
      current = false,
    },
    sort = {
      fields = { "idx" },
    },
    matcher = {
      sort_empty = false,
    },
    win = {
      input = {
        keys = {
          ["<C-n>"] = { "list_down", mode = { "i", "n" } },
          ["<C-p>"] = { "list_up", mode = { "i", "n" } },
        },
      },
      list = {
        keys = {
          ["<C-n>"] = "list_down",
          ["<C-p>"] = "list_up",
        },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if item and item.run then
        vim.schedule(item.run)
      end
    end,
  }
end

function M.pick_session()
  local agentic = require "agentic"
  local SessionRegistry = require "agentic.session_registry"

  SessionRegistry.get_session_for_tab_page(nil, function(session)
    session.agent:when_ready(function()
      session.agent:list_sessions(vim.fn.getcwd(), function(result, err)
        local items = { new_session_item(agentic) }

        if err then
          vim.notify("Failed to list Agentic sessions: " .. (err.message or "unknown error"), vim.log.levels.WARN)
        end

        for _, session_info in ipairs((result and result.sessions) or {}) do
          items[#items + 1] = restore_session_item(#items + 1, session, session_info)
        end

        vim.schedule(function()
          pick_items(items)
        end)
      end)
    end)
  end)
end

return M
