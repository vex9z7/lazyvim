return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.marksman = {
        -- Marksman uses the repository root for cross-file Markdown links.
        on_attach = function(client, buffer)
          vim.keymap.set("n", "gd", function()
            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
            client:request("textDocument/definition", params, function(err, result)
              if err or not result or vim.tbl_isempty(result) then
                vim.schedule(function()
                  vim.cmd.normal { args = { "gf" }, bang = true }
                end)
                return
              end
              vim.lsp.util.show_document(result, client.offset_encoding)
            end, buffer)
          end, { buffer = buffer, desc = "Goto Markdown Link" })
        end,
      }
    end,
  },
}
