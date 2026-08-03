local M = {}

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

local function items(agentic)
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

function M.pick()
  require("plugins.agentic.select").pick(items(require "agentic"), "Agentic Context")
end

return M
