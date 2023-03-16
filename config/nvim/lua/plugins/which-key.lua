require("which-key").setup({})
require("which-key").register({
	f = { "<cmd>Telescope find_files<cr>", "Find File" },
}, { prefix = "<leader>" })
