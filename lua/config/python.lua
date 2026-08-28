local M = {}

local function selected_python()
  local ok, selector = pcall(require, "venv-selector")
  local python = ok and selector.python() or nil
  if not python then
    vim.notify("Select a Python environment with <leader>cv first", vim.log.levels.WARN)
    return
  end
  return python
end

local function matching_kernel(python)
  local jupyter = vim.fn.stdpath "data" .. "/python/bin/jupyter"
  local result = vim.system({ jupyter, "kernelspec", "list", "--json" }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Could not list Jupyter kernels; see README.md", vim.log.levels.ERROR)
    return
  end

  local specs = vim.json.decode(result.stdout).kernelspecs or {}
  local target = vim.uv.fs_realpath(python)
  for name, spec in pairs(specs) do
    local argv = spec.spec and spec.spec.argv
    if argv and vim.uv.fs_realpath(argv[1]) == target then
      return name
    end
  end
end

local function start(kernel, action)
  if action then
    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenKernelReady",
      once = true,
      callback = action,
    })
  end
  vim.cmd.MoltenInit(kernel)
end

local function register_kernel(python, action, confirm)
  local function register()
    local project = vim.fs.basename(vim.fn.getcwd()):gsub("[^%w_-]", "-")
    local name = ("nvim-%s-%s"):format(project, vim.fn.sha256(python):sub(1, 8))
    local result = vim
      .system({
        python,
        "-m",
        "ipykernel",
        "install",
        "--user",
        "--name",
        name,
        "--display-name",
        "Python (" .. project .. ")",
      }, { text = true })
      :wait()

    if result.code ~= 0 then
      vim.notify(result.stderr, vim.log.levels.ERROR)
      return
    end
    start(name, action)
  end

  if not confirm then
    register()
    return
  end

  vim.ui.select({ "Register", "Cancel" }, {
    prompt = "No Jupyter kernel uses this venv. Register it?",
  }, function(choice)
    if choice == "Register" then
      register()
    end
  end)
end

local function initialize(action, python, kernel)
  python = python or selected_python()
  if not python then
    return
  end

  kernel = kernel or matching_kernel(python)
  if kernel then
    start(kernel, action)
    return
  end

  if vim.system({ python, "-c", "import ipykernel" }):wait().code == 0 then
    register_kernel(python, action, true)
    return
  end

  vim.ui.select({ "Install and register", "Cancel" }, {
    prompt = "The selected venv needs an ipykernel. Install and register it?",
  }, function(choice)
    if choice ~= "Install and register" then
      return
    end

    vim.notify "Installing ipykernel in the selected venv…"
    vim.system({ python, "-m", "pip", "install", "ipykernel" }, { text = true }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify(result.stderr, vim.log.levels.ERROR)
          return
        end
        register_kernel(python, action, false)
      end)
    end)
  end)
end

local function run(action)
  local python = selected_python()
  if not python then
    return
  end

  local kernel = matching_kernel(python)
  local running = vim.fn.MoltenRunningKernels(true)
  if kernel and vim.list_contains(running, kernel) then
    action()
    return
  end

  if #running > 0 then
    vim.cmd.MoltenDeinit()
  end
  initialize(action, python, kernel)
end

function M.run_cell()
  run(function()
    require("notebook-navigator").run_cell()
  end)
end

function M.run_cells_above()
  run(function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local end_line = #lines
    for line_number = cursor_line + 1, #lines do
      if lines[line_number]:match "^%s*#%s*%%%%" then
        end_line = line_number - 1
        break
      end
    end

    local cell_start = 1
    for line_number, line in ipairs(lines) do
      if line_number > end_line then
        break
      end
      if line:match "^%s*#%s*%%%%" then
        if cell_start < line_number then
          vim.fn.MoltenEvaluateRange(cell_start, line_number - 1)
        end
        cell_start = line_number + 1
      end
    end
    if cell_start <= end_line then
      vim.fn.MoltenEvaluateRange(cell_start, end_line)
    end
  end)
end

local function output_under_cursor()
  if vim.fn.exists "*MoltenRunningKernels" ~= 1 or #vim.fn.MoltenRunningKernels(true) == 0 then
    vim.notify("No Molten kernel or output is active in this buffer", vim.log.levels.INFO)
    return
  end

  local previous, previous_type = vim.fn.getreg '"', vim.fn.getregtype '"'
  local ok = pcall(vim.cmd.MoltenYankOutput)
  local output = vim.fn.getreg '"'
  vim.fn.setreg('"', previous, previous_type)
  if not ok or output == "" or output == "\n" then
    vim.notify("Move the cursor into an evaluated cell with output", vim.log.levels.INFO)
    return
  end
  return output
end

function M.show_output()
  local output = output_under_cursor()
  if not output then
    return
  end

  local lines = vim.split(output, "\n", { plain = true })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false

  local width = math.min(100, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Python Output ",
    title_pos = "center",
  })
  vim.wo[win].wrap = true
  for _, key in ipairs { "q", "<Esc>" } do
    vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, silent = true })
  end
end

function M.yank_output()
  local output = output_under_cursor()
  if not output then
    return
  end
  vim.fn.setreg("+", output, vim.fn.getregtype '"')
  vim.notify "Python output copied to clipboard"
end

function M.on_venv_changed()
  if vim.bo.filetype ~= "python" or vim.fn.exists "*MoltenRunningKernels" ~= 1 then
    return
  end

  local running = vim.fn.MoltenRunningKernels(true)
  if #running == 0 then
    return
  end

  local python = selected_python()
  local kernel = python and matching_kernel(python) or nil
  if kernel and vim.list_contains(running, kernel) then
    return
  end

  vim.cmd.MoltenDeinit()
  vim.notify "Molten kernel stopped; the selected venv will start on the next execution"
end

return M
