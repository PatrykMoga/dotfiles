-- Enable hidden/dotfiles in all search and finder tools
return {
  -- Telescope: show hidden files, respect .gitignore
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = { "%.git/" },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          additional_args = { "--hidden" },
        },
        grep_string = {
          additional_args = { "--hidden" },
        },
      },
    },
  },

  -- fzf-lua: show hidden files
  {
    "ibrahimgubri/fzf-lua",
    optional = true,
    opts = {
      files = {
        fd_opts = "--type f --hidden --exclude .git",
      },
      grep = {
        rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --glob '!.git/'",
      },
    },
  },

  -- Snacks explorer: show hidden files
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          files = {
            hidden = true,
            ignored = false,
          },
          grep = {
            hidden = true,
          },
        },
      },
    },
  },
}
