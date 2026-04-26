-- nvim-treesitter `main` branch (the master branch was archived in May 2025).
-- The new branch has no `setup{}` / `ensure_installed` / module system: parsers
-- are installed via `install()` and highlighting/indent are enabled per-buffer
-- by Neovim's built-in treesitter API.
local parsers = {
  'bash',
  'c',
  'css',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'query',
  'regex',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
}

local indent_disable = { python = true, c = true }

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',

  config = function()
    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local ft = args.match
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not pcall(vim.treesitter.start, bufnr, lang) then return end
        if not indent_disable[ft] then
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
