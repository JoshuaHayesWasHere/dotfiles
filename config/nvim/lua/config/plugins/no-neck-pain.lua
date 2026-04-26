return {
  'shortcuts/no-neck-pain.nvim',
  cmd = { 'NoNeckPain', 'NoNeckPainToggleLeftSide', 'NoNeckPainToggleRightSide' },
  opts = {
    width = 100,
    autocmds = {
      enableOnVimEnter = false,
      reloadOnColorSchemeChange = true,
    },
    mappings = { enabled = false },
    buffers = {
      setNames = true,
      scratchPad = { enabled = false },
      bo = { filetype = 'no-neck-pain' },
    },
  },
}
