-- Flexoki 500 colors with minimal styling
local colors = {
  blue = "#4385BE",
  green = "#879A39",
  purple = "#8B7EC8",
  red = "#D14D41",
  yellow = "#D0A215",
  base = "#878580",
  bg = "#1C1B1A",
}

local flexoki_minimal = {
  normal = {
    a = { fg = colors.blue, bg = colors.bg },
    b = { fg = colors.base, bg = colors.bg },
    c = { fg = colors.base, bg = colors.bg },
  },
  insert = { a = { fg = colors.green, bg = colors.bg } },
  visual = { a = { fg = colors.purple, bg = colors.bg } },
  replace = { a = { fg = colors.red, bg = colors.bg } },
  command = { a = { fg = colors.yellow, bg = colors.bg } },
  inactive = {
    a = { fg = colors.base, bg = colors.bg },
    b = { fg = colors.base, bg = colors.bg },
    c = { fg = colors.base, bg = colors.bg },
  },
}

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.theme = flexoki_minimal
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "|", right = "|" }

    opts.sections = opts.sections or {}
    opts.sections.lualine_y = {}  -- Remove duplicate progress/location
    opts.sections.lualine_z = { "progress", "location" }

    return opts
  end,
}
