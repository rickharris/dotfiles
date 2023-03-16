return require("packer").startup(function()
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use("tpope/vim-sensible")
	use("folke/tokyonight.nvim")
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"folke/which-key.nvim",
		event = "BufWinEnter",
		config = function()
			require("plugins.which-key")
		end,
	})
	use({
		"williamboman/nvim-lsp-installer",
		"neovim/nvim-lspconfig",
		setup = function()
			require("nvim-lsp-installer").setup({})
		end,
	})
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("plugins.null-ls")
		end,
	})
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})
	use({
		"gbprod/yanky.nvim",
		config = function()
			require("yanky").setup()
		end,
	})
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})
end)
