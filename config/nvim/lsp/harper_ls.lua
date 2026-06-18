return {
  cmd = { 'harper-ls', '--stdio' },
  filetypes = { 'markdown' },
  root_markers = { '.git' },
  settings = {
    ['harper-ls'] = {
      userDictPath = vim.fn.stdpath('data') .. '/site/spell/en.utf-8.add',
      linters = {
        SentenceCapitalization = false,
      },
    },
  },
}
