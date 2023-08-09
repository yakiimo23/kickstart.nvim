if vim.g.vscode then
  return {}
end
return {
  'rmagatti/auto-session',
  config = function()
    require('auto-session').setup {
      log_level = 'info',
      auto_session_suppress_dirs = {'~/', '~/Projects'}
    }
  end
}
