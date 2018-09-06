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
set undofile
set undodir=~/.vim/undo

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'lifepillar/vim-solarized8'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'jlanzarotta/bufexplorer'
Plug 'sheerun/vim-polyglot'
Plug 'simnalamburt/vim-mundo'
Plug 'w0rp/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'steelsojka/deoplete-flow'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

set bg=light
let g:solarized_statusline = "low"
colorscheme solarized8_flat

nnoremap <leader>t :Files<CR>

let g:ale_fixers = {
\   'go': ['goimports'],
\   'javascript': ['prettier'],
\   'ruby': ['rubocop'],
\}
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>

let g:deoplete#enable_at_startup = 1
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

let local_flow = finddir('node_modules', '.;') . '/.bin/flow'
if matchstr(local_flow, "^\/\\w") == ''
    let local_flow= getcwd() . "/" . local_flow
endif
if executable(local_flow)
  let g:deoplete#sources#flow#flow_bin = local_flow
endif

let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0

nnoremap <Leader>u :MundoToggle<CR>
