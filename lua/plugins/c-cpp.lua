local function project_root(patterns)
  local find_root = require("lspconfig.util").root_pattern(unpack(patterns))

  return function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    on_dir(find_root(name) or vim.fs.dirname(name))
  end
end

local clangd_cmd = {
  "clangd",
  "--background-index",
  "--clang-tidy",
  "--completion-style=detailed",
  "--header-insertion=iwyu",
}
local cxx = vim.fn.exepath "c++"
if cxx ~= "" then
  table.insert(clangd_cmd, "--query-driver=" .. cxx)
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "cmake", "make" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Keep compile flags and shared policy in each project: compile_commands.json,
      -- .clangd, .clang-tidy, and .clang-format. Do not add global flags here.
      opts.servers.clangd = {
        cmd = clangd_cmd,
        root_dir = project_root { "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", "Makefile", ".git" },
      }

      -- Project .neocmake.toml takes precedence over the optional XDG user config.
      -- Formatting stays in Conform so there is one formatter path.
      opts.servers.neocmake = {
        cmd = { "neocmakelsp", "stdio" },
        root_dir = project_root { "CMakePresets.json", "CMakeLists.txt", ".git" },
        single_file_support = true,
      }
    end,
  },
}
