return {
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    {
      'nvim-tree/nvim-tree.lua',
      version = '*',
      lazy = false,
      dependencies = {
        'nvim-tree/nvim-web-devicons',
      },
      config = function()
        require('nvim-tree').setup {}
      end,
    },
    {
      'nvim-neotest/neotest',
      dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-lua/plenary.nvim',
        'antoinemadec/FixCursorHold.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
      opts = {
        adapters = {
          ['neotest-dotnet'] = {},
        },
      },
      keys = {
        { '<leader>t', '', desc = '+[T]est' },
        {
          '<leader>tt',
          function()
            require('neotest').run.run(vim.fn.expand '%')
          end,
          desc = 'Run File',
        },
        {
          '<leader>tT',
          function()
            require('neotest').run.run(vim.uv.cwd())
          end,
          desc = 'Run All Test Files',
        },
        {
          '<leader>tr',
          function()
            require('neotest').run.run()
          end,
          desc = 'Run Nearest',
        },
        {
          '<leader>tl',
          function()
            require('neotest').run.run_last()
          end,
          desc = 'Run Last',
        },
        {
          '<leader>ts',
          function()
            require('neotest').summary.toggle()
          end,
          desc = 'Toggle Summary',
        },
        {
          '<leader>to',
          function()
            require('neotest').output.open { enter = true, auto_close = true }
          end,
          desc = 'Show Output',
        },
        {
          '<leader>tO',
          function()
            require('neotest').output_panel.toggle()
          end,
          desc = 'Toggle Output Panel',
        },
        {
          '<leader>tS',
          function()
            require('neotest').run.stop()
          end,
          desc = 'Stop',
        },
        {
          '<leader>tw',
          function()
            require('neotest').watch.toggle(vim.fn.expand '%')
          end,
          desc = 'Toggle Watch',
        },
      },
    },
  },
}
