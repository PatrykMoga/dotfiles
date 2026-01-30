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
