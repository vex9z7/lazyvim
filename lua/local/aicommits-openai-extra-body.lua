local M = {}

local patched = false

local function get_api_key(config)
  if config.api_key and config.api_key ~= "" then
    return config.api_key
  end

  local key = vim.env.AICOMMITS_NVIM_OPENAI_API_KEY
  if key and key ~= "" then
    return key
  end

  key = vim.env.OPENAI_API_KEY
  if key and key ~= "" then
    return key
  end

  return nil
end

function M.setup()
  if patched then
    return
  end

  local openai = require "aicommits.providers.openai"
  local request = require "aicommits.request"

  -- aicommits' OpenAI provider targets the standard chat-completions body.
  -- Some OpenAI-compatible endpoints need provider-specific top-level fields;
  -- merge config.extra_body after the common fields so those endpoints can opt in.
  function openai:generate_text(envelope, config, callback)
    local api_key = get_api_key(config)
    if not api_key then
      callback(
        "OpenAI API key not found. Set 'providers.openai.api_key' in config or environment variable AICOMMITS_NVIM_OPENAI_API_KEY or OPENAI_API_KEY",
        nil
      )
      return
    end

    local endpoint = config.endpoint or "https://api.openai.com/v1/chat/completions"

    local request_body = {
      model = envelope.model or config.model or "gpt-4.1-nano",
      messages = {
        { role = "system", content = envelope.system },
        { role = "user", content = envelope.user },
      },
      temperature = envelope.temperature,
      top_p = envelope.top_p,
      frequency_penalty = envelope.frequency_penalty,
      presence_penalty = envelope.presence_penalty,
      max_tokens = envelope.max_tokens,
      stream = false,
      n = envelope.n or 1,
    }

    if config.extra_body then
      request_body = vim.tbl_deep_extend("force", request_body, config.extra_body)
    end

    request.send({
      url = endpoint,
      headers = self:get_auth_headers(config),
      body = vim.json.encode(request_body),
      policy = request.resolve_policy(config),
    }, function(err, result)
      if err then
        callback(err, nil)
        return
      end

      local ok, response = pcall(vim.json.decode, result.body)
      if not ok then
        callback("Failed to parse OpenAI API response: " .. tostring(response), nil)
        return
      end

      if response.error then
        callback("OpenAI API Error: " .. (response.error.message or vim.inspect(response.error)), nil)
        return
      end

      if not response.choices or #response.choices == 0 then
        callback("No commit messages were generated. Try again.", nil)
        return
      end

      local texts = {}
      for _, choice in ipairs(response.choices) do
        if choice.message and choice.message.content then
          table.insert(texts, choice.message.content)
        end
      end

      callback(nil, texts)
    end)
  end

  patched = true
end

return M
