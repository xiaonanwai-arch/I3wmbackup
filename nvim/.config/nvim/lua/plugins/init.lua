return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

 { "typicode/bg.nvim", lazy = false },

-- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css"
  		},
  	},
  },
  -- lua/plugins/init.lua

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Add languages you want automatically installed
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "tsx",
        "python", "rust", "go", "c", "markdown", "markdown_inline"
      },
      -- Enable synchronous installation of parsers
      sync_install = false,
      -- Automatically install missing parsers when entering a buffer
      auto_install = true, 
      highlight = {
        enable = true, -- Ensure highlighting is active
      },
    },
  },
}

