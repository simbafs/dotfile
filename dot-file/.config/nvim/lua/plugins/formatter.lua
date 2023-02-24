-- Utilities for creating configurations
local filetypes = require("formatter.filetypes")

vim.keymap.set("n", "<leader>f", ":Format<CR>")

require("formatter").setup({
	logging = false,
	log_level = vim.log.levels.WARN,
	filetype = {
		typescript = filetypes.typescript.prettier,
		typescriptreact = filetypes.typescriptreact.prettier,
		javascript = filetypes.javascript.prettier,
		javascriptreact = filetypes.javascriptreact.prettier,
		css = filetypes.css.prettier,
		html = filetypes.html.prettier,
		json = filetypes.json.prettier,
		markdown = filetypes.markdown.prettier,
		yaml = filetypes.yaml.prettier,
		c = filetypes.c.clangformat,
		cpp = filetypes.cpp.clangformat,
		sh = filetypes.sh.shfmt,
		zsh = filetypes.sh.shfmt,
		lua = filetypes.lua.stylua,
		go = filetypes.go.gofmt,
		latex = filetypes.latex.latexindent,
		python = filetypes.python.autopep8,
		rust = filetypes.rust.rustfmt,
		toml = filetypes.toml.taplo,

		["*"] = require("formatter.filetypes.any").remove_trailing_whitespace,
	},
})
