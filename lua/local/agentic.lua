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

local function pick_items(opts)
  Snacks.picker.pick {
    source = opts.source,
    title = opts.title,
    finder = function()
      return opts.items
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
        { win = "list", title = opts.list_title, title_pos = "center", border = true },
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
      idx = 1,
      text = "Add selection or current file",
      run = function()
        agentic.add_selection_or_file_to_context()
      end,
    },
    {
      idx = 2,
      text = "Add diagnostics at cursor line",
      run = function()
        agentic.add_current_line_diagnostics()
      end,
    },
    {
      idx = 3,
      text = "Add all diagnostics from current buffer",
      run = function()
        agentic.add_buffer_diagnostics()
      end,
    },
    {
      idx = 4,
      text = "Add current file",
      run = function()
        agentic.add_file()
      end,
    },
    {
      idx = 5,
      text = "Add all listed file buffers",
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

function M.pick_context()
  local agentic = require "agentic"

  pick_items {
    source = "agentic_context_actions",
    title = "Agentic Context",
    list_title = " Context ",
    items = context_items(agentic),
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
          pick_items {
            source = "agentic_sessions",
            title = "Agentic Sessions",
            list_title = " Sessions ",
            items = items,
          }
        end)
      end)
    end)
  end)
end

return M
