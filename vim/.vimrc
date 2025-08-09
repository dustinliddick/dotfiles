" Basic settings
set nocompatible
set backspace=indent,eol,start
set ruler
set number
set showcmd
set incsearch
set hlsearch

" Enable syntax highlighting
syntax on

" Enable file type plugins
filetype plugin indent on

" Set encoding
set encoding=utf-8

" Set tabs and indentation
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

" Enable line numbers
set number
set relativenumber

" Highlight current line
set cursorline

" Show matching brackets
set showmatch

" Enable mouse support
set mouse=a

" Set color scheme
" Try to use a more modern colorscheme if available
silent! colorscheme catppuccin_mocha
silent! colorscheme desert
colorscheme default

" Status line
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}

" Search settings
set ignorecase
set smartcase
set incsearch
set hlsearch

" Turn off search highlight with <leader>h
nnoremap <leader>h :nohlsearch<CR>

" Enable wildmenu for command completion
set wildmenu
set wildmode=list:longest

" Better split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" More natural split opening
set splitbelow
set splitright

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Backup and swap settings
set backup
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" Create backup directories if they don't exist
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "", 0770)
endif
if !isdirectory($HOME."/.vim/backup")
    call mkdir($HOME."/.vim/backup", "", 0700)
endif
if !isdirectory($HOME."/.vim/swap")
    call mkdir($HOME."/.vim/swap", "", 0700)
endif
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "", 0700)
endif

" Save file as sudo when needed
cmap w!! w !sudo tee % >/dev/null

" Quickly edit and reload vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Remember cursor position
augroup vimrcEx
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
augroup END