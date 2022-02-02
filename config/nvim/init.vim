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

" Use coc for language server completions
let g:ale_disable_lsp = 1

call plug#begin('~/.config/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'lifepillar/vim-solarized8'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'jlanzarotta/bufexplorer'
Plug 'sheerun/vim-polyglot'
Plug 'simnalamburt/vim-mundo'
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

autocmd Signal SIGUSR1 call AutoDarkOrLight()

function! AutoDarkOrLight()
  let s:mode = systemlist("defaults read -g AppleInterfaceStyle")[0]

  if s:mode ==? "dark"
    let s:new_bg = "dark"
  else
    let s:new_bg = "light"
  endif

  if &background !=? s:new_bg
    let &background = s:new_bg
  endif

  redraw
endfunction

call AutoDarkOrLight()
autocmd vimenter * ++nested colorscheme solarized8_flat

nnoremap <leader>t :FZF<CR>
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>

let g:ale_fixers = {
      \   'javascript': ['eslint', 'prettier'],
      \   'typescript': ['eslint', 'prettier'],
      \   'typescriptreact': ['eslint', 'prettier'],
      \   'ruby': ['rubocop'],
      \}

let g:jsx_ext_required = 0

nnoremap <Leader>u :MundoToggle<CR>

" make FZF respect gitignore if `ag` is installed
if (executable('ag'))
  let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore ".git" -g ""'
endif

map <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
let g:bufExplorerShowRelativePath = 1
