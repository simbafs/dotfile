-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
	vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
	-- Package manager
	use 'wbthomason/packer.nvim'

	use { -- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		requires = {
			-- Automatically install LSPs to stdpath for neovim
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',

			-- Useful status updates for LSP
			'j-hui/fidget.nvim',

			-- Additional lua configuration, makes nvim stuff amazing
			'folke/neodev.nvim',
		},
	}
	require('neodev').setup()
	require('fidget').setup()

	use { -- Autocompletion
		'hrsh7th/nvim-cmp',
		requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
	}

	use { -- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		run = function()
			pcall(require('nvim-treesitter.install').update { with_sync = true })
		end,
	}

	use { -- Additional text objects via treesitter
		'nvim-treesitter/nvim-treesitter-textobjects',
		after = 'nvim-treesitter',
	}
	require('plugins.treesitter')

	-- Git related plugins
	use 'tpope/vim-fugitive'

	use 'tpope/vim-rhubarb'

	use 'lewis6991/gitsigns.nvim'
	require('plugins.gitsigns')

	use 'nvim-lualine/lualine.nvim' -- Fancier statusline
	require('plugins.lualine')

	-- gcc from a line comment, gbc from a block comment
	use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
	require('Comment').setup()

	-- use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically

	-- Fuzzy Finder (files, lsp, etc)
	use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }

	-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }
	require('plugins.telescope')

	use { "catppuccin/nvim", as = "catppuccin" }
	require('plugins.catppuccin')


	-- snippets
	use { 'rafamadriz/friendly-snippets' }
	use { 'hrsh7th/vim-vsnip' }
	use { 'honza/vim-snippets' }
	use { 'mattn/emmet-vim' }

	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons', -- optional, for file icons
		},
	}
	require("nvim-tree").setup()

	use { 'junegunn/vim-easy-align' }
	require('plugins.vimEasyAlign')

	use { 'ap/vim-css-color' }

	use { 'mbbill/undotree' }

	use { 'fatih/vim-go' }

	use { 'simrat39/symbols-outline.nvim' }
	require("symbols-outline").setup()

	use { 'echasnovski/mini.nvim', branch = 'stable' }
	require('plugins.mini')
	-- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
	-- local has_plugins, plugins = pcall(require, 'custom.plugins')
	-- if has_plugins then
	--   plugins(use)
	-- end
end)

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
	command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
	group = packer_group,
	pattern = vim.fn.expand '$MYVIMRC',
})

require('plugins.lspAndCmp')
