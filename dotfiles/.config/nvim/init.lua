vim.cmd([[packadd packer.nvim]])

require('packer').startup(function()
	use 'wbthomason/packer.nvim'

 	use 'nvim-tree/nvim-tree.lua'
	use 'nvim-lua/plenary.nvim'
    	use 'nvim-telescope/telescope.nvim'
     	use 'nvim-telescope/telescope-fzy-native.nvim'
     	use 'nvim-treesitter/nvim-treesitter'
      	use 'nvim-lualine/lualine.nvim'
  	use 'neovim/nvim-lspconfig'
   	use 'williamboman/mason.nvim'
    	use 'williamboman/mason-lspconfig.nvim'
     	use 'hrsh7th/nvim-cmp'
      	use 'hrsh7th/cmp-nvim-lsp'
       	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
 	use 'saadparwaiz1/cmp_luasnip'
  	use 'L3MON4D3/LuaSnip'
   	use 'tpope/vim-fugitive'
       	use 'kyazdani42/nvim-web-devicons'
 	use 'folke/tokyonight.nvim'
  	use 'morhetz/gruvbox'
  	use 'windwp/nvim-autopairs'
end)

require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = { 'asm_lsp', 'bashls', 'clangd', 'cssls', 'html', 'pyright', 'ts_ls' },
	automatic_installation = true
})

local lspconfig = require('lspconfig')
lspconfig.asm_lsp.setup{}
lspconfig.bashls.setup{}
lspconfig.clangd.setup{}
lspconfig.cssls.setup{}
lspconfig.html.setup{}
lspconfig.pyright.setup{}
lspconfig.ts_ls.setup{}

local cmp = require('cmp')
cmp.setup({
	sources = {
 		{ name = 'nvim_lsp' },
   		{ name = 'buffer' },
     		{ name = 'path' },
       		{ name = 'luasnip' }
	}
})

require'nvim-treesitter.configs'.setup {
	ensure_installed = { "bash", "c", "cpp", "css", "html", "javascript", "nasm", "python" },
 	hightlight = {
  		enable = true,
	},
 	indent = {
  		enable = true,
	}
 }

 require('lualine').setup({
 	options = {
  		theme = 'gruvbox',
    		section_separators = '',
      		component_separators = '|',
	},
 })

 require'nvim-tree'.setup {
 	disable_netrw = true,
  	hijack_netrw = true,
   	update_cwd = true,
    	update_focused_file = {
     		enable = true,
       		update_cwd = true,
	},
 	renderer = {
  		highlight_opened_files = "all",
    		icons = {
      			show = {
	 			git = true,
     				folder = true,
	 			file = true,
     				folder_arrow = true
	 		}
    		}
      	}
}

require("nvim-autopairs").setup({})

vim.cmd[[colorscheme gruvbox]]

vim.o.autoindent = true
vim.o.number = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.tabstop = 4

vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
