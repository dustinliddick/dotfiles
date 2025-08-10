" Vim Configuration
" Based on wookayin's comprehensive vim setup
" Enhanced fallback configuration when Neovim is not available

" Compatibility settings
if &compatible
  set nocompatible
endif

" Basic settings
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set ttyfast
set backspace=indent,eol,start
set ruler
set number
set showcmd
set incsearch
set hlsearch

" Leader key
let mapleader = " "
let maplocalleader = ","

" Enable syntax highlighting
syntax on

" Enable file type plugins
filetype plugin indent on

" Set tabs and indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent
set smarttab

" Enable line numbers
set number
set relativenumber

" Highlight current line
set cursorline

" Show matching brackets
set showmatch

" Enable mouse support
set mouse=a

" Colors and themes
if has('termguicolors')
  set termguicolors
endif
set background=dark

" Try to use better color schemes
silent! colorscheme gruvbox
silent! colorscheme onedark
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

" Clear search highlighting
nnoremap <Esc> :nohlsearch<CR>
nnoremap <leader>h :nohlsearch<CR>

" Better escape
inoremap jk <Esc>

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

" File operations
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa!<CR>

" Buffer navigation
nnoremap <S-l> :bnext<CR>
nnoremap <S-h> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Better indenting
vnoremap < <gv
vnoremap > >gv

" Move text up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Stay in center when jumping
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

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

" Auto commands
augroup VimConfig
  autocmd!
  
  " Remove trailing whitespace on save
  autocmd BufWritePre * :%s/\s\+$//e
  
  " Remember cursor position
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  
  " File type specific settings
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType rust setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4 softtabstop=4
  
  " Enable spell check for text files
  autocmd FileType gitcommit,markdown,text setlocal spell spelllang=en_us
augroup END

" Functions
" Toggle relative numbers
function! ToggleRelativeNumbers()
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
nnoremap <leader>tr :call ToggleRelativeNumbers()<CR>

" Create directory if it doesn't exist when saving
function! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir)
      call mkdir(dir, 'p')
    endif
  endif
endfunction
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END