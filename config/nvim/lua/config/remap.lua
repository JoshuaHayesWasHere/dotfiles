-- Move visually selected lines
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Moves whole line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Moves whole line up' })

-- Diagnostics
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Show diagnostics [Q]uickfix list' })
vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float(nil, { focusable = true })
end, { desc = 'Show line [D]iagnostics' })

--Buffer navigation
vim.keymap.set('n', '<Tab>', ':bn<CR>', { desc = 'Switches to next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { desc = 'Switches to previous buffer' })

-- Split window navigation: CTRL+<hjkl>
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move left."<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move right"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move up"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move down"<CR>')

-- nvimTree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Toggle wrap; while on, j/k navigate by display line
vim.keymap.set('n', '<leader>w', function()
  vim.wo.wrap = not vim.wo.wrap
  if vim.wo.wrap then
    vim.keymap.set('n', 'j', 'gj')
    vim.keymap.set('n', 'k', 'gk')
    print('wrap on (j/k → gj/gk)')
  else
    pcall(vim.keymap.del, 'n', 'j')
    pcall(vim.keymap.del, 'n', 'k')
    print('wrap off')
  end
end, { desc = 'Toggle [W]rap and j/k → gj/gk' })

-- Misc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clears search highlight' })
vim.keymap.set(
  'n',
  '<leader>s',
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = 'Find and replace word under cursor' }
)

