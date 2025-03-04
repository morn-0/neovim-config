local lspconfig = require('lspconfig')
local lspconfig_util = require('lspconfig.util')
local protocol = require('vim.lsp.protocol')
local cmp = require('blink.cmp')

local on_attach = function(client, bufnr)
  if client.name == 'rust-analyzer' then
    client.server_capabilities.semanticTokensProvider = nil
  end

  if client.name == 'yamlls' then
    client.server_capabilities.documentFormattingProvider = true
  end

  local opt = { noremap = true, silent = true }
  local function mapbuf(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  mapbuf('n', '<leader>ra', '<cmd>lua vim.lsp.buf.rename()<CR>', opt)
  mapbuf('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opt)
  mapbuf('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
  mapbuf('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opt)
  mapbuf('n', 'gd', '<cmd>Glance definitions<CR>', opt)
  mapbuf('n', 'gi', '<cmd>Glance implementations<CR>', opt)
  mapbuf('n', 'gr', '<cmd>Glance references<CR>', opt)
  mapbuf('n', 'gt', '<cmd>Glance type_definitions<CR>', opt)
  mapbuf('n', 'go', '<cmd>lua vim.diagnostic.open_float()<CR>', opt)
  mapbuf('n', 'gk', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opt)
  mapbuf('n', 'gj', '<cmd>lua vim.diagnostic.goto_next()<CR>', opt)

  local cmd = '<cmd>lua require(\'conform\').format({ async = true, lsp_fallback = true })<CR>'
  mapbuf('n', '<leader>f', cmd, { noremap = true })

  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup('DocumentHighlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = 'DocumentHighlight',
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = 'DocumentHighlight',
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

lspconfig.lua_ls.setup({
  on_attach = on_attach,
})

lspconfig.jsonls.setup({
  on_attach = on_attach,
})

lspconfig.taplo.setup({
  on_attach = on_attach,
})

lspconfig.yamlls.setup({
  on_attach = on_attach,
})

lspconfig.clangd.setup({
  on_attach = on_attach,
})

lspconfig.html.setup({
  on_attach = on_attach,
  capabilities = cmp.get_lsp_capabilities((function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  end)())
})

lspconfig.cssls.setup {
  on_attach = on_attach,
  capabilities = cmp.get_lsp_capabilities((function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  end)())
}

local function typescript_root_dir(fname)
  local root_dir = lspconfig_util.root_pattern 'tsconfig.json' (fname) or lspconfig_util.root_pattern('package.json', 'jsconfig.json', '.git')(fname)

  local node_modules_index = root_dir and root_dir:find('node_modules', 1, true)
  if node_modules_index and node_modules_index > 0 then
    root_dir = root_dir:sub(1, node_modules_index - 2)
  end

  return root_dir
end

local function typescript_capabilities()
  local capabilities = {
    textDocumentSync = protocol.TextDocumentSyncKind.Incremental,
    executeCommandProvider = {
      commands = {
        'invoke_additional_rename',
        'call_api_function',
        'request_references',
        'request_implementations'
      },
    },
    renameProvider = {
      prepareProvider = false,
    },
    completionProvider = {
      resolveProvider = true,
      triggerCharacters = {
        '.',
        '"',
        '\'',
        '`',
        '/',
        '@',
        '<',
      },
    },
    hoverProvider = true,
    definitionProvider = true,
    typeDefinitionProvider = true,
    inlayHintProvider = true,
    foldingRangeProvider = true,
    semanticTokensProvider = {
      documentSelector = nil,
      legend = {
        tokenTypes = {
          'class',
          'enum',
          'interface',
          'namespace',
          'typeParameter',
          'type',
          'parameter',
          'variable',
          'enumMember',
          'property',
          'function',
          'member',
        },
        tokenModifiers = {
          'declaration',
          'static',
          'async',
          'readonly',
          'defaultLibrary',
          'local',
        },
      },
      full = true,
    },
    declarationProvider = false,
    implementationProvider = true,
    referencesProvider = true,
    documentSymbolProvider = true,
    documentHighlightProvider = true,
    signatureHelpProvider = {
      triggerCharacters = { '(', ',', '<' },
      retriggerCharacters = { ')' },
    },
    codeActionProvider = {
      codeActionKinds = {
        '',
        'quickfix',
        'refactor',
        'refactor.extract',
        'refactor.inline',
        'refactor.rewrite',
        'source',
        'source.organizeImports'
      },
      resolveProvider = true,
    },
    workspace = {
      fileOperations = {
        willRename = {
          filters = {
            {
              scheme = 'file',
              pattern = { glob = '**/*.{ts,js,jsx,tsx,mjs,mts,cjs,cts}', matches = 'file' },
            },
            {
              scheme = 'file',
              pattern = { glob = '**/*', matches = 'folder' },
            },
          },
        },
      },
    },
    documentFormattingProvider = true,
    documentRangeFormattingProvider = true,
    callHierarchyProvider = true,
    workspaceSymbolProvider = true,
    codeLensProvider = {
      resolveProvider = true,
    },
  }
  return capabilities
end

lspconfig.ts_ls.setup({
  on_attach = on_attach,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx'
  },
  root_dir = typescript_root_dir,
  single_file_support = true,
  capabilities = cmp.get_lsp_capabilities(typescript_capabilities())
})

local M = {}

M.joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

M.uv = vim.uv or vim.loop

M.is_windows = function()
  local sysname = M.uv.os_uname().sysname
  return sysname == 'Windows' or sysname == 'Windows_NT'
end

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

M.get_active_rust_clients = function(bufnr, filter)
  filter = vim.tbl_deep_extend('force', filter or {}, {
    name = 'rust-analyzer',
  })
  if bufnr then
    filter.bufnr = bufnr
  end
  return M.get_clients(filter)
end

M.starts_with_windows_drive_letter = function(path)
  return path:match('^%a:') ~= nil
end

M.normalize_path_on_windows = function(path)
  if M.is_windows() and M.starts_with_windows_drive_letter(path) then
    return path:sub(1, 1):lower() .. path:sub(2):gsub('/+', '\\')
  end
  return path
end

local function parse_snippet_fallback(input)
  local output = input
      -- $0 -> Nothing
      :gsub('%$%d', '')
      -- ${0:_} -> _
      :gsub('%${%d:(.-)}', '%1')
      :gsub([[\}]], '}')
  return output
end

local function parse_snippet(input)
  local ok, parsed = pcall(function()
    return vim.lsp._snippet_grammar.parse(input)
  end)
  return ok and tostring(parsed) or parse_snippet_fallback(input)
end

function M.snippet_text_edits_to_text_edits(text_edits)
  if type(text_edits) ~= 'table' then
    return
  end
  for _, value in ipairs(text_edits) do
    if value.newText and value.insertTextFormat then
      value.newText = parse_snippet(value.newText)
    end
  end
end

local function get_active_client_root(file_name)
  local cargo_home = M.uv.os_getenv('CARGO_HOME') or M.joinpath(vim.env.HOME, '.cargo')
  local registry = M.joinpath(cargo_home, 'registry', 'src')

  local rustup_home = M.uv.os_getenv('RUSTUP_HOME') or M.joinpath(vim.env.HOME, '.rustup')
  local toolchains = M.joinpath(rustup_home, 'toolchains')

  for _, item in ipairs { toolchains, registry } do
    item = M.normalize_path_on_windows(item)
    if file_name:sub(1, #item) == item then
      local clients = M.get_active_rust_clients()
      return clients and #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

local function rust_root_dir(file_name)
  local reuse_active = get_active_client_root(file_name)
  if reuse_active then
    return reuse_active
  end
  local path = vim.fs.dirname(file_name)
  if not path then
    return nil
  end
  local cargo_crate_dir = vim.fs.dirname(vim.fs.find({ 'Cargo.toml' }, {
    upward = true,
    path = path,
  })[1])
  local cargo_workspace_dir = nil
  if vim.fn.executable('cargo') == 1 then
    local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
    if cargo_crate_dir ~= nil then
      cmd[#cmd + 1] = '--manifest-path'
      cmd[#cmd + 1] = M.joinpath(cargo_crate_dir, 'Cargo.toml')
    end
    local cargo_metadata = ''
    local cm = vim.fn.jobstart(cmd, {
      on_stdout = function(_, d, _)
        cargo_metadata = table.concat(d, '\n')
      end,
      stdout_buffered = true,
      cwd = path,
    })
    if cm > 0 then
      cm = vim.fn.jobwait({ cm })[1]
    else
      cm = -1
    end
    if cm == 0 then
      cargo_workspace_dir = vim.fn.json_decode(cargo_metadata)['workspace_root']
    end
  end
  return cargo_workspace_dir
      or cargo_crate_dir
      or vim.fs.dirname(vim.fs.find({ 'rust-project.json' }, {
        upward = true,
        path = path,
      })[1])
end

local function mk_rustcap()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.experimental = {
    hoverActions = true,
    colorDiagnosticOutput = true,
    hoverRange = true,
    serverStatusNotification = true,
    snippetTextEdit = true,
    codeActionGroup = true,
    ssr = true
  }
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' }
  }
  capabilities.experimental.commands = {
    commands = {
      'rust-analyzer.runSingle',
      'rust-analyzer.showReferences',
      'rust-analyzer.gotoLocation',
      'editor.action.triggerParameterHints'
    }
  }
  return capabilities
end

local function mk_rustcap_if_available(mod_name, callback)
  local available, mod = pcall(require, mod_name)
  if available and type(mod) == 'table' then
    local ok, capabilities = pcall(callback, mod)
    if ok then
      return capabilities
    end
  end
  return {}
end

local function rustcap()
  local rs_capabilities = mk_rustcap()
  local cmp_capabilities = mk_rustcap_if_available('cmp_nvim_lsp', function(cmp_nvim_lsp)
    return cmp_nvim_lsp.default_capabilities()
  end)
  local selection_range_capabilities = mk_rustcap_if_available('lsp-selection-range', function(lsp_selection_range)
    return lsp_selection_range.update_capabilities {}
  end)
  local folding_range_capabilities = mk_rustcap_if_available('ufo', function(_)
    return {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true
        }
      }
    }
  end)
  return vim.tbl_deep_extend(
    'force',
    rs_capabilities,
    cmp_capabilities,
    selection_range_capabilities,
    folding_range_capabilities
  )
end

lspconfig.rust_analyzer.setup({
  name = 'rust-analyzer',
  filetypes = { 'rust' },
  on_init = function()
    local old_func = vim.lsp.util.apply_text_edits

    vim.lsp.util.apply_text_edits = function(edits, bufnr, offset_encoding)
      M.snippet_text_edits_to_text_edits(edits)
      old_func(edits, bufnr, offset_encoding or 'utf-8')
    end
  end,
  on_attach = on_attach,
  root_dir = rust_root_dir,
  capabilities = cmp.get_lsp_capabilities(rustcap()),
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        -- target = 'i686-pc-windows-msvc'
      },
      diagnostics = {
        enable = true,
      },
      inlayHints = {
        maxLength = 512
      },
      checkOnSave = {
        allFeatures = true,
        command = 'clippy',
        extraArgs = { '--no-deps' },
      }
    }
  }
})

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*/Cargo.toml',
  callback = function()
    local clients = vim.lsp.get_active_clients()

    for _, client in ipairs(clients) do
      if client.name == 'rust_analyzer' then
        client.request('rust-analyzer/reloadWorkspace', nil, function(err)
          if err then
            error(tostring(err))
          end
        end, 0)
      end
    end
  end,
  group = vim.api.nvim_create_augroup('RustToolsAutocmds', { clear = true }),
})
