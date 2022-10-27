set t_Co=256                    " enable 256-color mode.
syntax enable                   " enable syntax highlighting.
"set number                      " show line numbers
set nohlsearch                  " Don't continue to highlight searched phrases.
set incsearch                   " But do highlight as you type your search.
set ignorecase                  " Make searches case-insensitive.
set autoindent                  " auto-indent
set tabstop=4                   " tab spacing
set expandtab                   " use spaces instead of tabs
"colorscheme delek               " change color scheme
"set mouse=a                     " turn mouse functionality on
set ruler                       " enable ruler
set backspace=indent,eol,start  " fix backspace problems
" Set true color
if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
  set termguicolors
endif
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"


" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
Plug 'drewtempelmeyer/palenight.vim'
Plug 'lifepillar/vim-solarized8'
call plug#end()

" Post-plug config
set background=dark
colorscheme palenight
" Palenight color config
let g:palenight_termcolors=16
let g:palenight_terminal_italics=1
