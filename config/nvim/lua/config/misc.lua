-- THIS FILE IS LOADED BEFORE THE PLUGINS

-- No automatic comment insertion
vim.cmd([[autocmd FileType * set formatoptions-=ro]])

-- Yanking highlight
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlights text when yanking',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Rebuild spell .spl when the .add file is modified externally (e.g. by harper-ls
-- "Add to dictionary" action). Without this, native spell keeps using the stale
-- binary and underlines words harper has already accepted.
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
  desc = 'Rebuild spellfile if .add is newer than .spl',
  group = vim.api.nvim_create_augroup('spellfile-rebuild', { clear = true }),
  callback = function()
    local add = vim.fn.stdpath('data') .. '/site/spell/en.utf-8.add'
    if vim.fn.filereadable(add) == 0 then return end
    if vim.fn.getftime(add) > vim.fn.getftime(add .. '.spl') then
      vim.cmd('silent! mkspell! ' .. vim.fn.fnameescape(add))
    end
  end,
})

-- Rounded floating windows
vim.diagnostic.config({
  float = {
    border = 'rounded',
    max_width = 80,
  },
})

-- Close all buffers except the current one
function CloseAllBuffersExceptCurrent()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    -- Skip the current buffer
    if buf ~= current_buf then
      -- Check if the buffer is loaded and not modified
      if vim.api.nvim_buf_is_loaded(buf) and not vim.bo.modified then
        -- Delete the buffer
        vim.api.nvim_buf_delete(buf, { force = false })
      end
    end
  end

  local has_notify, notify = pcall(require, 'notify')
  if has_notify then
    vim.notify = notify
  end
  vim.notify('Closed all buffers except current', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('BufOnly', function()
  CloseAllBuffersExceptCurrent()
end, { desc = 'Close all buffers except current' })

vim.keymap.set('n', '<Leader>bo', CloseAllBuffersExceptCurrent, { desc = 'Close all buffers except current' })

-- Trim Microsoft line endings
function Trim()
  local save = vim.fn.winsaveview()
  vim.cmd('keeppatterns %s/\\s\\+$\\|\\r$//e')
  vim.fn.winrestview(save)

  local has_notify, notify = pcall(require, 'notify')
  if has_notify then
    vim.notify = notify
  end
  vim.notify('Trimmed ^M line endings', vim.log.levels.INFO)
end

vim.keymap.set('n', '<Leader>tt', Trim, { desc = 'Trimmed ^M line endings' })
