return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'tpope/vim-sensible'
  use 'folke/tokyonight.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
    "folke/which-key.nvim",
    event = "BufWinEnter",
    config = function()
      require("which-key").setup({})
      require("which-key").register({
        f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
      }, { prefix = "<leader>" })
    end
  }
end)
