-- Local Agentic UI helpers. Keep picker-independent action/session wiring here
-- and let vim.ui.select provide the shared picker UI.
local M = {}

local function select_item(items, opts)
  vim.ui.select(items, {
    prompt = opts.prompt,
    format_item = function(item)
      return item.label
    end,
  }, function(item)
    if item and item.run then
      item.run()
    end
  end)
end

local function current_file_buffers()
  local files = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" then
        files[#files + 1] = bufnr
      end
    end
  end
  return files
end

local function context_items(agentic)
  return {
    {
      label = "Add selection or current file",
      run = function()
        agentic.add_selection_or_file_to_context()
      end,
    },
    {
      label = "Add diagnostics at cursor line",
      run = function()
        agentic.add_current_line_diagnostics()
      end,
    },
    {
      label = "Add all diagnostics from current buffer",
      run = function()
        agentic.add_buffer_diagnostics()
      end,
    },
    {
      label = "Add current file",
      run = function()
        agentic.add_file()
      end,
    },
    {
      label = "Add all listed file buffers",
      run = function()
        local files = current_file_buffers()
        if #files == 0 then
          vim.notify("No listed file buffers to add to Agentic", vim.log.levels.INFO)
          return
        end
        agentic.add_files_to_context { files = files }
      end,
    },
  }
end

local function session_label(session_info)
  local updated_at = session_info.updatedAt and session_info.updatedAt:sub(1, 16):gsub("T", " ") or "unknown date"
  local title = session_info.title or "(no title)"

  return string.format("%s - %s", updated_at, title), updated_at, title
end

function M.pick_context()
  select_item(context_items(require "agentic"), { prompt = "Agentic Context" })
end

function M.pick_session()
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
          select_item(items, { prompt = "Agentic Sessions" })
        end)
      end)
    end)
  end)
end

return M
