let mapleader = ";"
:let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

set number "line numbers
set autoread "reload changed files automatically
set hidden "switch between buffers without saving
set laststatus=2 "show status bar
set nofoldenable "don't fold my code, either
set nowrap "no wrapping please, thank you
set scrolloff=8 "start scrolling when cursor is 8 rows away from edge
set sidescrolloff=8 "start scrolling when cursor is 8 columns away from edge

set incsearch "Find the next match as we type the search
set hlsearch "Hilight searches by default
set ignorecase "Ignore case for searches...
set smartcase " ... unless you use a capital letter in search

set autoindent "match indentation on newlines
set smartindent "attempt to be smart about indenting/un-indenting newlines
set smarttab "treat a series of spaces as tabs when appropriate
set shiftwidth=2 "two-space indention width
set softtabstop=2
set tabstop=2
set expandtab "use spaces instead of tabs

set colorcolumn=81

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'altercation/vim-colors-solarized'
Plug 'icymind/NeoSolarized'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-commentary'
Plug 'neomake/neomake'
Plug 'benjie/neomake-local-eslint.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'fatih/vim-go'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
call plug#end()

let g:solarized_visibility="low" "very low contrast listchars
set bg="dark"
colorscheme NeoSolarized
autocmd! BufWritePost * Neomake
let g:neomake_javascript_enabled_makers = ['eslint', 'flow']
let g:go_fmt_command = "goimports"
let g:deoplete#enable_at_startup = 1
let g:tern#filetypes = ['javascript.jsx']
