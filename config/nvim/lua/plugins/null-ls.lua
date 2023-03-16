local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

require("null-ls").setup({
	-- you can reuse a shared lspconfig on_attach callback here
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					vim.lsp.buf.formatting_sync()
				end,
			})
		end
	end,
	sources = {
		require("null-ls").builtins.diagnostics.luacheck,
		require("null-ls").builtins.formatting.stylua,
		require("null-ls").builtins.diagnostics.eslint_d,
		require("null-ls").builtins.formatting.eslint_d,
		require("null-ls").builtins.formatting.prettier,
		require("null-ls").builtins.completion.spell,
		require("null-ls").builtins.diagnostics.jsonlint,
		require("null-ls").builtins.diagnostics.markdownlint,
		require("null-ls").builtins.diagnostics.rubocop,
		require("null-ls").builtins.diagnostics.shellcheck,
		require("null-ls").builtins.diagnostics.stylelint,
		require("null-ls").builtins.diagnostics.zsh,
	},
})
