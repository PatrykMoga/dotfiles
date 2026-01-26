-- Flexoki 400 colors
local colors = {
  blue = "#4385BE",
  green = "#879A39",
  orange = "#DA702C",
  purple = "#8B7EC8",
  red = "#D14D41",
  yellow = "#D0A215",
  base = "#878580",
  bg = "#1C1B1A",
  bg_2 = "#282726",
  black = "#100F0F",
}

-- Flat style: colored text on bg background, no colored backgrounds
local flexoki_minimal = {
  normal = {
    a = { fg = colors.blue, bg = colors.bg, gui = "bold" },
    b = { fg = colors.base, bg = colors.bg_2 },
    c = { fg = colors.base, bg = colors.bg },
  },
  insert = { a = { fg = colors.green, bg = colors.bg, gui = "bold" } },
  visual = { a = { fg = colors.purple, bg = colors.bg, gui = "bold" } },
  replace = { a = { fg = colors.red, bg = colors.bg, gui = "bold" } },
  command = { a = { fg = colors.yellow, bg = colors.bg, gui = "bold" } },
  inactive = {
    a = { fg = colors.base, bg = colors.bg_2 },
    b = { fg = colors.base, bg = colors.bg_2 },
    c = { fg = colors.base, bg = colors.bg },
  },
}

-- Edge components for rounded corners
local left_edge = {
  function()
    return ""
  end,
  color = { fg = colors.bg, bg = colors.black },
  padding = 0,
}

local right_edge = {
  function()
    return ""
  end,
  color = { fg = colors.bg, bg = colors.black },
  padding = 0,
}

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.theme = flexoki_minimal
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }

    opts.sections = opts.sections or {}
    opts.sections.lualine_a = { left_edge, "mode" }
    opts.sections.lualine_y = {} -- Remove duplicate progress/location
    opts.sections.lualine_z = { "progress", "location", right_edge }

    return opts
  end,
}
