-- Swift/SwiftUI support (uses Xcode's sourcekit-lsp)
return {
  -- treesitter parser
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "swift" },
    },
  },

  -- LSP configuration for sourcekit-lsp
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          -- sourcekit-lsp comes with Xcode, no mason install needed
          cmd = { "sourcekit-lsp" },
          filetypes = { "swift", "objc", "objcpp" },
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace")(filename)
              or util.find_git_ancestor(filename)
          end,
        },
      },
    },
  },
}
