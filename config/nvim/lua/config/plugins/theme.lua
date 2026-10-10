return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,          -- load early so colors are ready
  priority = 1000,       -- ensure it wins over other UIs
  opts = {
    flavour = "frappe",    -- latte, frappe, macchiato, mocha
    transparent_background = false,
    float = { transparent = false, solid = false },
    show_end_of_buffer = false,
    term_colors = false,
    dim_inactive = { enabled = false, shade = "dark", percentage = 0.15 },
    no_italic = false,
    no_bold = false,
    no_underline = false,
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    auto_integrations = false,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      mini = {
        enabled = true,
        indentscope_color = "", -- empty => use theme default
      },
    },
  },
  config = function(_, opts)
    -- Defer to plugin's setup so options in `opts` are applied
    require("catppuccin").setup(opts)
    -- Apply colorscheme after setup so highlights are correct
    vim.cmd.colorscheme("catppuccin")
  end,
}
