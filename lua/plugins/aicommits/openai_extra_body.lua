-- Patch aicommits.nvim's OpenAI provider to support extra top-level request
-- body fields for OpenAI-compatible local endpoints.
local M = {}

local patched = false

function M.setup()
  if patched then
    return
  end

  local openai = require "aicommits.providers.openai"
  local request = require "aicommits.request"
  local generate_text = openai.generate_text
  local send = request.send

  function openai:generate_text(envelope, config, callback)
    if not config.extra_body then
      return generate_text(self, envelope, config, callback)
    end

    request.send = function(opts, cb)
      local ok, body = pcall(vim.json.decode, opts.body or "")
      if ok and type(body) == "table" then
        opts = vim.tbl_extend("force", {}, opts, {
          body = vim.json.encode(vim.tbl_deep_extend("force", body, config.extra_body)),
        })
      end
      return send(opts, cb)
    end

    local ok, err = pcall(generate_text, self, envelope, config, callback)
    request.send = send
    if not ok then
      error(err)
    end
  end

  patched = true
end

return M
