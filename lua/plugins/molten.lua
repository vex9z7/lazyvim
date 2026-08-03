return {
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = "python",
    init = function()
      local function set_highlights()
        vim.api.nvim_set_hl(0, "MoltenVirtualText", {
          fg = "#8d9cc4",
          bg = "#2f334d",
          italic = false,
        })
      end
      set_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("molten_highlights", { clear = true }),
        callback = set_highlights,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        once = true,
        callback = function()
          local python = vim.fn.stdpath "data" .. "/python/bin/python"
          if vim.fn.executable(python) ~= 1 then
            vim.notify("Molten requires an isolated Neovim Python host; see README.md", vim.log.levels.WARN)
            return
          end

          vim.system({ python, "-c", "import pynvim, jupyter_client" }, {}, function(result)
            if result.code ~= 0 then
              vim.schedule(function()
                vim.notify("Molten Python host is missing pynvim or jupyter_client; see README.md", vim.log.levels.WARN)
              end)
            end
          end)
        end,
      })

      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "none"
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_max_lines = 12
      vim.g.molten_virt_text_truncate = "bottom"
      vim.g.molten_wrap_output = true
    end,
    keys = {
      {
        "<leader>jo",
        function()
          require("config.python").show_output()
        end,
        desc = "Show Python Output",
        ft = "python",
      },
      {
        "<leader>jy",
        function()
          require("config.python").yank_output()
        end,
        desc = "Copy Python Output",
        ft = "python",
      },
      { "<leader>jr", "<cmd>MoltenRestart!<cr>", desc = "Restart Python Kernel", ft = "python" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt Python Kernel", ft = "python" },
    },
  },
}
