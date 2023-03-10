local rt = require('rust-tools')

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

      require('keybindings').mapLSP(buf_set_keymap)
    end,
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          -- target = "wasm32-unknown-unknown"
        }
      }
    }
  }
})
