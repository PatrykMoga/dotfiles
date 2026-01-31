return {
  {
    "kepano/flexoki-neovim",
    name = "flexoki",
    lazy = false,
    priority = 1000,
    config = function()
      require("flexoki").setup({
        highlight_groups = {
          -- NeoTree file explorer
          NeoTreeNormal = { bg = "#100F0F" },
          NeoTreeNormalNC = { bg = "#100F0F" },
          NeoTreeEndOfBuffer = { bg = "#100F0F" },
          -- Float windows and popups
          NormalFloat = { bg = "#100F0F" },
          Pmenu = { bg = "#100F0F" },
          -- WhichKey popup
          WhichKeyFloat = { bg = "#100F0F" },

          -- TypeScript/JavaScript keywords
          ["@keyword.type"] = { fg = "#8B7EC8" },
          ["@keyword.import"] = { fg = "#8B7EC8" },
          ["@keyword.export"] = { fg = "#8B7EC8" },

          -- Types and interfaces
          ["@type"] = { fg = "#4385BE" },
          ["@type.builtin"] = { fg = "#4385BE" },

          -- HTML/JSX/Astro tags
          ["@tag"] = { fg = "#DA702C" },
          ["@tag.builtin"] = { fg = "#DA702C" },
          ["@tag.attribute"] = { fg = "#D0A215" },
          ["@tag.delimiter"] = { fg = "#3AA99F" },

          -- Strings
          ["@string"] = { fg = "#879A39" },

          -- Punctuation
          ["@punctuation.bracket"] = { fg = "#878580" },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "flexoki-dark",
    },
  },
}
