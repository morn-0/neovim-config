local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

mason.setup({})
mason_lspconfig.setup({
  -- ensure_installed = { 'lua_ls', 'jsonls', 'taplo', 'yamlls', 'html', 'cssls', 'ts_ls', 'rust_analyzer', 'clangd' }
  ensure_installed = { 'lua_ls', 'jsonls', 'taplo', 'yamlls', 'html', 'cssls', 'ts_ls', 'rust_analyzer' }
})
