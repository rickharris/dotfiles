""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" IMPORTANT FIRST STEPS                                                      {{{

" Use ; for <Leader> and , for <LocalLeader>
let mapleader = ";"
let maplocalleader = ","

" Don't pretend we're vi (because why, really)
set nocompatible

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NEOBUNDLE                                                                  {{{

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'rking/ag.vim'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'int3/vim-extradite'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'henrik/vim-indexed-search'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'gregsexton/MatchTag'
NeoBundle 'juvenn/mustache.vim'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-rake'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'ervandew/supertab'
NeoBundle 'tpope/vim-surround'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'duwanis/tomdoc.vim'
NeoBundle 'vim-scripts/YankRing.vim'
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'altercation/vim-colors-solarized'

NeoBundleCheck

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPTIONS                                                                    {{{
" see :help <option> for each <option> set here
set autoindent
set autoread
set background=dark
set backspace=indent,eol,start
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set colorcolumn=81
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set encoding=utf-8
set expandtab
set formatoptions=tcrqn21
set hidden
set history=100
set hlsearch
set ignorecase
set incsearch
set keywordprg=
set laststatus=2
set linebreak
set listchars=tab:▸\ ,eol:¬,trail:☠
set mouse=a
set noerrorbells
set number
set ruler
set scrolloff=3
set shiftround
set shiftwidth=2
set shortmess=filmnrxtTI
set showbreak=↪
set showcmd
set showmatch
set showmode
set smartcase
set smartindent
set softtabstop=2
set splitbelow
set t_Co=256
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
set tabstop=2
set textwidth=80
set title
set undodir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set undofile
set visualbell
set whichwrap+=<,>,h,l
set wildmenu
set wildmode=longest,list
set wrap

colorscheme solarized
filetype plugin indent on
syntax enable
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL KEYBINDINGS                                                         {{{

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General                                                                    {{{

" Use ;ve to edit the .vimrc
noremap <Leader>ve       :e $MYVIMRC<CR>
" Use ;vs to source the .vimrc
noremap <Leader>vs       :so $MYVIMRC<CR>

" Use ;o/;O to insert lines below/above the current one without having to dirty
" yourself with insert mode
noremap <Leader>o        o<ESC>k
noremap <Leader>O        O<ESC>j

" Use Y to yank the rest of the current line
noremap Y y$

" Reverse j/k's behavior with gj/gk
nnoremap j  gj
nnoremap k  gk
nnoremap gj j
nnoremap gk k

" Use jk as a replacement for escape in both insert and command modes
inoremap jk <Esc>
cnoremap jk <Esc>

" Use kj as a replacement for escape in both insert and command modes
inoremap kj <Esc>
cnoremap kj <Esc>

" Shortcut for paste mode
nmap <leader>sp :set paste! paste?<CR>

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ag.vim                                                                     {{{

" Search for the current word under the cursor using ag
nnoremap <Leader>A *<C-O>:AgFromSearch!<CR>

" Prompt to search with ag
nnoremap <Leader>a :Ag!<SPACE>"<LEFT>"

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlP

" remap the ctrlp shortcut
let g:ctrlp_map = '<Leader>t'
" use Ag for searching (speed improvement)
let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

" }}}

" }}}

