local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

mason.setup({})
mason_lspconfig.setup({
  ensure_installed = { 'jdtls', 'lemminx', 'lua_ls', 'jsonls', 'taplo', 'yamlls', 'html', 'cssls', 'tsserver', 'volar', 'rust_analyzer', 'clangd' },
})
