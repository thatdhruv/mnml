set autoindent
set clipboard=unnamedplus
set encoding=utf-8
set mouse=a
set nocompatible
set number
set shiftwidth=4
set smartindent
set tabstop=4
set termguicolors

cal plug#begin('~/.vim/plugged')
  Plug 'morhetz/gruvbox'

  Plug 'preservim/nerdtree'

  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vir-airline-themes'

  Plug 'neoclide/coc.nvim'

  Plug 'jiangmiao/auto-pairs'

  Plug 'mattn/emmet-vim'

  Plug 'tpope/vim-commentary'

  Plug 'nvim-treesitter/nvim-treesitter'

  Plug 'ryanoasis/vim-devicons'
call plug#end()

syntax enable
colorscheme gruvbox
set background=dark

let g:airline_theme = 'gruvbox'

let g:AutoPairsFlyMode = 1

let g:user_emmet_expandabbr_key = '<Tab>'

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

nnoremap <C-n> :NERDTreeToggle<CR>
