local Util = require("tokyonight.util")

local M = {}

---@type table<string, Palette|fun(opts:tokyonight.Config):Palette>
M.styles = setmetatable({}, {
  __index = function(_, style)
    return vim.deepcopy(Util.mod("tokyonight.colors." .. style))
  end,
})

---@param opts? tokyonight.Config
function M.setup(opts)
  -- cache functions and config
  opts = require("tokyonight.config").extend(opts)
  local blend = Util.blend_bg
  local brighten = Util.brighten
  
  Util.day_brightness = opts.day_brightness

  local palette = M.styles[opts.style]
  if type(palette) == "function" then
    palette = palette(opts) --[[@as Palette]]
  end

  ---@class ColorScheme: Palette
  local colors = palette
  local bg = colors.bg
  local dark = colors.bg_dark

  Util.bg = bg
  Util.fg = colors.fg
  colors.none = "NONE"

  -- optimized diff calculation
  colors.diff = {
    add    = blend(colors.green2, 0.25),
    delete = blend(colors.red1, 0.25),
    change = blend(colors.blue7, 0.15),
    text   = colors.blue7,
  }

  colors.git.ignore = colors.dark3
  colors.black = blend(bg, 0.8, "#000000")
  colors.border_highlight = blend(colors.blue1, 0.8)
  colors.border = colors.black

  -- constant assignments
  colors.bg_popup = dark
  colors.bg_statusline = dark

  -- helper to resolve background styles
  local function get_bg_style(style)
    if style == "transparent" then return colors.none end
    if style == "dark" then return dark end
    return bg
  end

  colors.bg_sidebar = get_bg_style(opts.styles.sidebars)
  colors.bg_float   = get_bg_style(opts.styles.floats)

  colors.bg_visual = blend(colors.blue0, 0.4)
  colors.bg_search = colors.blue0
  colors.fg_sidebar = colors.fg_dark
  colors.fg_float = colors.fg

  -- semantic colors
  colors.error   = colors.red1
  colors.todo    = colors.blue
  colors.warning = colors.yellow
  colors.info    = colors.blue2
  colors.hint    = colors.teal

  colors.rainbow = {
    colors.blue, colors.yellow, colors.green, colors.teal,
    colors.magenta, colors.purple, colors.orange, colors.red,
  }

  -- terminal palette optimization
  local term = {
    black          = colors.black,
    black_bright   = colors.terminal_black,
    red            = colors.red,
    green          = colors.green,
    yellow         = colors.yellow,
    blue           = colors.blue,
    magenta        = colors.magenta,
    cyan           = colors.cyan,
    white          = colors.fg_dark,
    white_bright   = colors.fg,
  }

  -- auto-generate bright variants
  colors.terminal = vim.tbl_extend("force", term, {
    red_bright     = brighten(term.red),
    green_bright   = brighten(term.green),
    yellow_bright  = brighten(term.yellow),
    blue_bright    = brighten(term.blue),
    magenta_bright = brighten(term.magenta),
    cyan_bright    = brighten(term.cyan),
  })

  opts.on_colors(colors)

  return colors, opts
end

return M
