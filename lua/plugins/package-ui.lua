local function selected_python()
  local python = require("venv-selector").python()
  if not python then
    vim.notify("Select a Python environment with <leader>cv first", vim.log.levels.WARN)
  end
  return python
end

return {
  {
    "MonsieurTib/package-ui.nvim",
    cmd = "VenvPackageUI",
    keys = {
      { "<leader>pU", "<cmd>VenvPackageUI<cr>", desc = "Manage Python packages" },
    },
    config = function()
      require("package-ui").setup()

      require("package-ui.services.python.base_service").get_pip_command = function()
        local python = selected_python()
        return python and { python, "-m", "pip" } or nil
      end

      vim.api.nvim_create_user_command("VenvPackageUI", function()
        if not selected_python() then
          return
        end

        local requirements = vim.fn.getcwd() .. "/requirements.txt"
        if vim.fn.filereadable(requirements) == 1 then
          vim.cmd.PackageUI()
          return
        end

        vim.ui.select({ "Create requirements.txt", "Cancel" }, {
          prompt = "PackageUI needs a requirements.txt for this pip project",
        }, function(choice)
          if choice == "Create requirements.txt" then
            vim.fn.writefile({ "# Project dependencies, managed with PackageUI." }, requirements)
            vim.cmd.PackageUI()
          end
        end)
      end, { desc = "Open PackageUI for the selected Python environment" })
    end,
  },
}
