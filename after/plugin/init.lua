-- [[ Custom Setting Options ]]

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.list = true
vim.opt.listchars = { tab = '»-', space = '_', eol = '↲'}
vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
-- vim.opt.spelllang = 'en,cjk'
-- vim.opt.spell = true
vim.opt.foldmethod = 'syntax'

-- [[ Custom Keymaps ]]

-- Toggle Tree
vim.keymap.set('n', '<leader>ff', ':NvimTreeToggle<CR>', { desc = 'Finder' })

-- Switch Tabs
vim.keymap.set('n', '<C-h>', 'gT', { desc = 'Previous Tab' })
vim.keymap.set('n', '<C-l>', 'gt', { desc = 'Next Tab' })

-- Disable highlight after search
vim.keymap.set('n', '<leader>nn', ':noh<CR>', { desc = 'Disable hignlight' })

-- Copy Relative Path
vim.keymap.set('n', 'rp', ':let @+ = expand("%")<CR>', { desc = 'Copy Relative Path' })

-- Emacs Keybindings

vim.keymap.set('i', '<C-p>', '<Up>')
vim.keymap.set('i', '<C-n>', '<Down>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')

-- Lazygit
vim.keymap.set('n', '<leader>lg', ':LazyGit<CR>', { desc = 'Lazygit' })

-- Open In GitHub
vim.keymap.set('n', '<leader>ogr', ':OpenInGHRepo<CR>', { desc = 'Open In GitHub Repository' })
vim.keymap.set('n', '<leader>ogf', ':OpenInGHFile<CR>', { desc = 'Open In GitHub File' })

-- Lsp Saga
vim.keymap.set('n', 'K', ':Lspsaga hover_doc<CR>', { desc = 'Lsp Hover Doc' })
vim.keymap.set('n', '<leader>ca', ':Lspsaga code_action<CR>', { desc = 'Lsp Code Action' })
vim.keymap.set('n', '[e', ':Lspsaga diagnostic_jump_next<CR>')
vim.keymap.set('n', ']e', ':Lspsaga diagnostic_jump_prev<CR>')

-- Ruby LSP
local function setup_diagnostics(client, buffer)
  if require("vim.lsp.diagnostic")._enable then
    return
  end

  local diagnostic_handler = function()
    local params = vim.lsp.util.make_text_document_params(buffer)
    client.request("textDocument/diagnostic", { textDocument = params }, function(err, result)
      if err then
        local err_msg = string.format("diagnostics error - %s", vim.inspect(err))
        vim.lsp.log.error(err_msg)
      end
      if not result then
        return
      end
      vim.lsp.diagnostic.on_publish_diagnostics(
        nil,
        vim.tbl_extend("keep", params, { diagnostics = result.items }),
        { client_id = client.id }
      )
    end)
  end

  diagnostic_handler() -- to request diagnostics on buffer when first attaching

  local _timers = {}
  vim.api.nvim_buf_attach(buffer, false, {
    on_lines = function()
      if _timers[buffer] then
        vim.fn.timer_stop(_timers[buffer])
      end
      _timers[buffer] = vim.fn.timer_start(200, diagnostic_handler)
    end,
    on_detach = function()
      if _timers[buffer] then
        vim.fn.timer_stop(_timers[buffer])
      end
    end,
  })
end

require('lspconfig').ruby_ls.setup({
  on_attach = function(client, buffer)
    setup_diagnostics(client, buffer)
  end,
})
