local function pick_session()
  local agentic = require "agentic"
  local SessionRegistry = require "agentic.session_registry"

  SessionRegistry.get_session_for_tab_page(nil, function(session)
    session.agent:when_ready(function()
      session.agent:list_sessions(vim.fn.getcwd(), function(result, err)
        local items = {
          {
            idx = 1,
            text = "New session",
            run = function()
              agentic.new_session()
            end,
          },
        }

        if err then
          vim.notify("Failed to list Agentic sessions: " .. (err.message or "unknown error"), vim.log.levels.WARN)
        end

        for _, saved_session in ipairs((result and result.sessions) or {}) do
          local updated_at = saved_session.updatedAt and saved_session.updatedAt:sub(1, 16):gsub("T", " ")
            or "unknown date"
          local title = saved_session.title or "(no title)"
          local session_id = saved_session.sessionId

          items[#items + 1] = {
            idx = #items + 1,
            text = string.format("%s - %s", updated_at, title),
            run = function()
              session:load_acp_session(session_id, title, updated_at)
              session.widget:show()
            end,
          }
        end

        vim.schedule(function()
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
        end)
      end)
    end)
  end)
end

return {
  {
    "carlos-algms/agentic.nvim",
    keys = {
      {
        "<leader>aa",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v" },
        desc = "Toggle Agentic chat",
      },
      {
        "<leader>aA",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file/selection to Agentic",
      },
      {
        "<leader>as",
        pick_session,
        mode = { "n", "v" },
        desc = "Pick Agentic session",
      },
      {
        "<leader>ap",
        function()
          require("agentic").switch_provider()
        end,
        mode = { "n", "v" },
        desc = "Switch Agentic provider",
      },
      {
        "<leader>ad",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = "n",
        desc = "Add line diagnostics to Agentic",
      },
      {
        "<leader>aD",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = "n",
        desc = "Add buffer diagnostics to Agentic",
      },
    },
    opts = {
      provider = "opencode-acp",
      diff_preview = {
        layout = "inline",
      },
    },
  },
}
