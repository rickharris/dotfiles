-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
vim.o.clipboard = ""
lvim.format_on_save.enabled = true
lvim.colorscheme = "tokyonight"

lvim.builtin.telescope.defaults.prompt_prefix = lvim.icons.ui.ChevronRight .. " "
lvim.builtin.telescope.defaults.selection_caret = lvim.icons.ui.Triangle .. " "
lvim.builtin.telescope.theme = "ivy"
lvim.builtin.telescope.on_config_done = function(telescope)
	pcall(telescope.load_extension, "neoclip")
end

lvim.builtin.which_key.mappings["b"] = {
	e = {
		"<cmd>Telescope buffers sort_mru=1 ignore_current_buffer=1 color_devicons=0<cr>",
		"Buffer Explorer",
	},
	o = { "<cmd>:BWipeout other<cr>", "Close other buffers" },
}
lvim.builtin.which_key.mappings["d"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Trouble" }
lvim.builtin.which_key.mappings["f"] = {
	function()
		require("lvim.core.telescope.custom-finders").find_project_files({ previewer = true })
	end,
	"Find File",
}
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["ss"] = { "<cmd>Telescope neoclip layout=vertical<cr>", "Yank History" }
lvim.builtin.which_key.mappings["se"] = {
	function()
		require("spectre").open()
	end,
	"Find and Replace",
}

local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "eslint_d" },
	{ command = "prettier" },
	{ command = "stylelint" },
	{ command = "rubocop" },
	{ command = "shfmt" },
	{ command = "stylua" },
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{ command = "eslint_d" },
	{ command = "stylelint" },
	{ command = "rubocop" },
	{ command = "gitlint" },
})

local code_actions = require("lvim.lsp.null-ls.code_actions")
code_actions.setup({
	{ name = "eslint_d" },
	{ name = "gitsigns" },
})

lvim.plugins = {
	{ "rickharris/nvim-solarized-lua" },
	{ "folke/tokyonight.nvim" },
	{
		"rose-pine/neovim",
		name = "rose-pine",
	},
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
	{ "kazhala/close-buffers.nvim" },
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = {
			{
				"tami5/sqlite.lua",
				module = "sqlite",
			},
			{ "nvim-telescope/telescope.nvim" },
		},
		config = function()
			require("neoclip").setup({
				enable_persistent_history = true,
			})
		end,
	},
	{
		"windwp/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ "kdheepak/lazygit.nvim" },
	{ "tpope/vim-surround" },
	{
		"gbprod/yanky.nvim",
		config = function()
			require("yanky").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	},
	{ "gpanders/editorconfig.nvim" },
	{
		"cormacrelf/dark-notify",
		config = function()
			require("dark_notify").run({
				schemes = {
					dark = {
						colorscheme = "tokyonight",
					},
					light = {
						colorscheme = "rose-pine-dawn",
					},
				},
			})
		end,
	},
}

vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)", {})
vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)", {})
vim.keymap.set("x", "p", "<Plug>(YankyPutAfter)", {})
vim.keymap.set("x", "P", "<Plug>(YankyPutBefore)", {})
vim.keymap.set("n", "gp", "<Plug>(YankyGPutAfter)", {})
vim.keymap.set("n", "gP", "<Plug>(YankyGPutBefore)", {})
vim.keymap.set("x", "gp", "<Plug>(YankyGPutAfter)", {})
vim.keymap.set("x", "gP", "<Plug>(YankyGPutBefore)", {})

vim.api.nvim_set_keymap("n", "<c-n>", "<Plug>(YankyCycleForward)", {})
vim.api.nvim_set_keymap("n", "<c-p>", "<Plug>(YankyCycleBackward)", {})
