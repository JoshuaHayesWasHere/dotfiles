-- Brave Kitty (Navy · Blade Silver), the T3 Code theme in ~/repos/brave-kitty-theme,
-- laid over catppuccin's palette slots so every catppuccin integration follows it.
-- Neutrals are the T3 theme's own colour roles; syntax hues are cool, moonlit tints.
local brave_kitty = {
  -- syntax accents
  rosewater = "#eedfe8",
  flamingo = "#e6c4d4",
  pink = "#d2b0f5",
  mauve = "#a99cff", -- keywords
  red = "#f08aa0",
  maroon = "#e0a2b8", -- parameters
  peach = "#e8b796", -- numbers, constants
  yellow = "#e9dcae", -- types (moonlight)
  green = "#9fd3c6", -- strings
  teal = "#86cbd6",
  sky = "#8ec5ff", -- operators
  sapphire = "#7fb0ff",
  blue = "#6f9bff", -- functions
  lavender = "#d4dcec", -- Blade Silver: fields, current line number
  -- text
  text = "#e4eaf7",
  subtext1 = "#b4c0dc",
  subtext0 = "#8796bd",
  overlay2 = "#7584ab", -- comments
  overlay1 = "#5d6d99",
  overlay0 = "#4a5a85",
  -- surfaces
  surface2 = "#1f3576",
  surface1 = "#172a5c",
  surface0 = "#0c1838",
  base = "#02050f",
  mantle = "#01030b",
  crust = "#000207",
}

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false, -- load early so colors are ready
  priority = 1000, -- ensure it wins over other UIs
  opts = {
    flavour = "mocha",
    transparent_background = false,
    float = { transparent = false, solid = false },
    show_end_of_buffer = false,
    term_colors = true,
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
    color_overrides = { mocha = brave_kitty },
    custom_highlights = function(c)
      return {
        LineNr = { fg = "#2e4280" },
        CursorLineNr = { fg = c.lavender, style = { "bold" } },
        CursorLine = { bg = "#060d22" },
        WinSeparator = { fg = "#12204a" },
        FloatBorder = { fg = "#1f3576", bg = c.mantle },
        NormalFloat = { bg = c.mantle },
        Visual = { bg = "#1a3170", style = {} },
        Search = { bg = "#1a3170", fg = "#ffffff" },
        IncSearch = { bg = c.lavender, fg = c.base },
        CurSearch = { bg = c.lavender, fg = c.base },
        MatchParen = { fg = c.lavender, bg = c.surface1, style = { "bold" } },
      }
    end,
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
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
