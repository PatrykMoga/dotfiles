-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()
local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- Modify the on_attach function to enable inlay hints correctly
local on_attach = function(client, bufnr)
  nvlsp.on_attach(client, bufnr)
  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, {bufnr=0})
  end
end

-- EXAMPLE
local servers = { "html", "cssls", "pyright", "tsserver" }  -- Add more servers as needed

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,  -- Use our modified on_attach function
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- Specific setup for rust_analyzer
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,  -- Use our modified on_attach function
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    ["rust-analyzer"] = {
      inlayHints = {
        enable = true,
      },
    },
  },
}

lspconfig.csharp_ls.setup {
  on_attach = on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities
}
-- Set highlight for inlay hints
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#888888", bg = "NONE" })

-- Add keybinding to toggle inlay hints with a new shortcut
vim.api.nvim_set_keymap('n', '<leader>ih', '<cmd>lua vim.lsp.inlay_hint.enable(nil, {bufnr=0})<CR>', {noremap = true, silent = true, desc = "Toggle Inlay Hints"})
