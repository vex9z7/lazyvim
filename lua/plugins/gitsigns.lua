return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>ga",
        function()
          vim.cmd.update()
          local file = vim.api.nvim_buf_get_name(0)
          local root = vim.fs.root(file, { ".git" })
          if not root then
            vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
            return
          end
          local result = vim
            .system({ "git", "-C", root, "add", "--", vim.fs.relpath(root, file) }, { text = true })
            :wait()
          if result.code ~= 0 then
            vim.notify(result.stderr, vim.log.levels.ERROR)
            return
          end
          require("gitsigns").refresh()
        end,
        desc = "Git Add Current File",
      },
    },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "+" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },
}
