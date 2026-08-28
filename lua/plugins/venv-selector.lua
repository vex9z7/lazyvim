return {
  {
    "linux-cultist/venv-selector.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      local previous = opts.options.on_venv_activate_callback
      opts.options.on_venv_activate_callback = function()
        if previous then
          previous()
        end
        require("config.python").on_venv_changed()
      end
    end,
  },
}
