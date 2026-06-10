-- Clipboard integration for local terminals, SSH sessions, and SSH inside tmux.
-- Normal yanks use the system clipboard; SSH uses OSC52; SSH inside tmux wraps
-- OSC52 in tmux passthrough.

-- Diagnostic logging for clipboard troubleshooting. This records provider
-- selection and payload sizes, never clipboard contents.
local log_path = vim.fn.stdpath("state") .. "/dotnvim/clipboard.log"

local function log(message)
  vim.fn.mkdir(vim.fn.fnamemodify(log_path, ":h"), "p")
  vim.fn.writefile({ string.format("%s %s", os.date("%Y-%m-%dT%H:%M:%S%z"), message) }, log_path, "a")
end

local function is_ssh()
  return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
end

local function is_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function provider_name()
  if not is_ssh() then
    return "auto"
  end

  if is_tmux() then
    return "osc52-tmux"
  end

  return "osc52"
end

local function encode_base64(text)
  if vim.base64 and vim.base64.encode then
    return vim.base64.encode(text)
  end

  log("base64=fallback-command")
  return vim.fn.system({ "base64", "-w", "0" }, text):gsub("%s+$", "")
end

local function copy_with_osc52(lines, _)
  local text = table.concat(lines, "\n")
  local encoded = encode_base64(text)
  local sequence = "\027]52;c;" .. encoded .. "\007"

  if is_tmux() then
    sequence = "\027Ptmux;\027" .. sequence:gsub("\027", "\027\027") .. "\027\\"
  end

  log(string.format("copy provider=%s lines=%d chars=%d encoded=%d", provider_name(), #lines, #text, #encoded))

  local ok, err = pcall(function()
    -- OSC52 is a terminal control sequence, not buffer output. Writing it to
    -- stderr follows common OSC52 plugin practice and keeps it away from any
    -- stdout content that Neovim or jobs may be producing.
    io.stderr:write(sequence)
    io.stderr:flush()
  end)
  log(string.format("write ok=%s bytes=%d%s", ok, #sequence, err and (" error=" .. tostring(err)) or ""))
end

local function paste_from_unnamed_register()
  log("paste fallback=unnamed-register")
  return vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"')
end

local function setup_clipboard()
  -- Make normal yanks, deletes, and pastes use the system clipboard register.
  vim.o.clipboard = "unnamedplus"

  -- For local terminals, let Neovim choose the provider. Over SSH, provide
  -- OSC52 explicitly so copies can reach the client clipboard.
  if is_ssh() then
    vim.g.clipboard = {
      name = provider_name(),
      copy = { ["+"] = copy_with_osc52, ["*"] = copy_with_osc52 },
      -- OSC52 paste/read is not consistently supported by terminals, so paste
      -- falls back to Neovim's unnamed register instead of querying the terminal.
      paste = { ["+"] = paste_from_unnamed_register, ["*"] = paste_from_unnamed_register },
    }
  end

  log(
    string.format(
      "setup provider=%s clipboard=%s ssh=%s tmux=%s term=%s",
      provider_name(),
      vim.o.clipboard,
      is_ssh() and "1" or "0",
      is_tmux() and "1" or "0",
      vim.env.TERM or ""
    )
  )
end

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("dotnvim_clipboard", { clear = true }),
  pattern = "VeryLazy",
  once = true,
  callback = function()
    -- Run after other VeryLazy handlers so this override wins over LazyVim's
    -- SSH clipboard default.
    vim.schedule(setup_clipboard)
  end,
})
