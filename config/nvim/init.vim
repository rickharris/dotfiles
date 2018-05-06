let mapleader = ";"
set termguicolors

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
Plug 'lifepillar/vim-solarized8'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
Plug 'cloudhead/neovim-fuzzy'
Plug 'jlanzarotta/bufexplorer'
Plug 'w0rp/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'steelsojka/deoplete-flow'
Plug 'pangloss/vim-javascript', {'for': ['javascript', 'javascript.jsx']}
Plug 'mxw/vim-jsx', {'for': ['javascript', 'javascript.jsx']}
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'rking/ag.vim'
call plug#end()

let g:solarized_statusline = "low"
colorscheme solarized8_flat

nnoremap <leader>t :FuzzyOpen<CR>

let g:ale_fixers = {
\   'javascript': ['eslint'],
\   'go': ['goimports'],
\}
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1

let g:deoplete#enable_at_startup = 1
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

function! StrTrim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction

let g:flow_path = StrTrim(system('PATH=$(npm bin):$PATH && which flow'))

if g:flow_path != 'flow not found'
  let g:deoplete#sources#flow#flow_bin = g:flow_path
endif

let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0
