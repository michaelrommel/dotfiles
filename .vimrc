set nocompatible

if empty(glob('~/.vim/autoload/plug.vim'))
  silent! curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" -----------------------------------------------------------------------------
" disable sleuth-like polyglot extension, seems to revert expandtab too often
" -----------------------------------------------------------------------------
let g:polyglot_disabled = ['autoindent']

" Gruvbox theme.
call plug#begin('~/.vim/plugged')
" Gruvbox theme.
Plug 'gruvbox-community/gruvbox'
" Integrate fzf with Vim.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jesseleite/vim-agriculture'
Plug 'airblade/vim-rooter'
" Automatically set 'shiftwidth' + 'expandtab' (indention) based on file type.
"Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
" Dim paragraphs above and below the active paragraph.
Plug 'junegunn/limelight.vim'
" Distraction free writing by removing UI elements and centering everything.
Plug 'junegunn/goyo.vim'
Plug 'reedes/vim-pencil'
Plug 'bling/vim-airline'
Plug 'vim-ctrlspace/vim-ctrlspace'
Plug 'preservim/vim-wheel'
" File Types and Languages
" Syntax Highlighting etc for many languates
Plug 'sheerun/vim-polyglot'
"Plug 'pangloss/vim-javascript'
"Plug 'elzr/vim-json'
Plug 'tmux-plugins/vim-tmux'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown'
Plug 'gyim/vim-boxdraw'
Plug 'habamax/vim-asciidoctor'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }
" Linters
Plug 'w0rp/ale'
" Completion Engine, release branch
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'takac/vim-hardtime'
"Plug 'ryanoasis/vim-devicons'
call plug#end()

" -----------------------------------------------------------------------------
" Color settings
" -----------------------------------------------------------------------------
silent! colorscheme gruvbox
" For Gruvbox to look correct in terminal Vim you'll want to source a palette
" script that comes with the Gruvbox plugin.
"
" Add this to your ~/.profile file:
"   source "$HOME/.vim/plugged/gruvbox/gruvbox_256palette.sh"
" Gruvbox comes with both a dark and light theme.
set background=dark
" Gruvbox has 'hard', 'medium' (default) and 'soft' contrast options.
let g:gruvbox_contrast_light='medium'
" This needs to come last, otherwise the colors aren't correct.
syntax on

" Enable true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  " setting this, disables italics in neovim!
  " set termguicolors
endif

let g:limelight_conceal_ctermfg = 'DarkGray'

" -----------------------------------------------------------------------------
" Misc settings
" -----------------------------------------------------------------------------
filetype plugin indent on
filetype indent on
filetype plugin on

exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list
set laststatus=2
set statusline=%<%f%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P
set colorcolumn=81
set fileformats=unix,mac,dos
set autoindent
set cindent
set backspace=indent,eol,start
set showmatch
set number
set relativenumber
set hlsearch
set expandtab
set smarttab
set hidden
set showtabline=0
set tabstop=2
set softtabstop=2
set shiftwidth=2
set splitright
set splitbelow
set modeline
set modelines=3
set clipboard=unnamed
set virtualedit=all
set foldmethod=marker

highlight Comment cterm=italic

"syntax match eq "==" conceal cchar=≣
"syntax match neq "!=" conceal cchar=≠
"syntax match gteq ">=" conceal cchar=≥
"syntax match lteq "<=" conceal cchar=≤
"setlocal conceallevel=1

let mapleader=","
if has("unix")
  let s:uname = system("uname -s")
  if s:uname =~ "Darwin"
    " override only on macos
    let mapleader=","
  endif
endif

nnoremap <leader>f :Files<CR>
nnoremap <leader>t :Tags<CR>

" -----------------------------------------------------------------------------
" EXPERIMENTS
" -----------------------------------------------------------------------------
set mouse=n

" WSL yank support
" let s:clip = '/mnt/c/Windows/System32/clip.exe'
" if executable(s:clip)
"   augroup WSLYank
"     autocmd!
"     autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
"   augroup END
" endif

" set clipboard+=unnamedplus
" let g:clipboard = {
"           \   'name': 'win32yank-wsl',
"           \   'copy': {
"           \      '+': '/mnt/c/ProgramFiles/Win32Yank/win32yank.exe -i --crlf',
"           \      '*': '/mnt/c/ProgramFiles/Win32Yank/win32yank.exe -i --crlf',
"           \    },
"           \   'paste': {
"           \      '+': '/mnt/c/ProgramFiles/Win32Yank/win32yank.exe -o --lf',
"           \      '*': '/mnt/c/ProgramFiles/Win32Yank/win32yank.exe -o --lf',
"           \   },
"           \   'cache_enabled': 0,
"           \ }

"set clipboard=unnamedplus
"autocmd TextYankPost * call system('echo '.shellescape(join(v:event.regcontents, "\<CR>")).' | /mnt/c/ProgramFiles/Win32Yank/win32yank.exe -i --crlf')

set clipboard=unnamedplus
if system('uname -a | egrep "[Mm]icrosoft"') != ''
  " only do this on Windows
  let g:lastyank = 'y'
  augroup myYank
    " remove all other autommands in this group, allow for multiple loadings
    autocmd!
    " This function copies the yanked text into the system clipboard on
    " Windows
    autocmd TextYankPost * if v:event.operator == 'y' | let g:miroyankbuffer = deepcopy(v:event.regcontents) | call YankDebounced() | let g:lastyank='' | else | let g:lastyank='' | endif

    function! Yank(timer)
      if system('uname -a | egrep "[Mm]icrosoft"') != ''
        " only do this on Windows
        if exists('$DISPLAY') && executable('xclip')
          call system('echo '.shellescape(join(g:miroyankbuffer, "\<CR>")).' | xclip -i -selection clipboard')
        else
          call system('echo '.shellescape(join(g:miroyankbuffer, "\<CR>")).' | /mnt/c/ProgramFiles/Win32Yank/win32yank.exe -i --crlf')
        endif
      else
        " on Linux
        call system('echo '.shellescape(join(g:miroyankbuffer, "\<CR>")).' | xclip -i -selection clipboard')
      endif
      let g:lastyank='y'
      redraw!
    endfunction

    " set the time, after which only the last yank will be put in the
    " clipboard, since this is an expensive call
    let g:yank_debounce_time_ms = 1000
    let g:yank_debounce_timer_id = -1

    function! YankDebounced()
      let l:now = localtime()
      call timer_stop(g:yank_debounce_timer_id)
      let g:yank_debounce_timer_id = timer_start(g:yank_debounce_time_ms, 'Yank')
    endfunction

  augroup END
  function! Paste(mode)
     if g:lastyank == 'y'
        if exists('$DISPLAY') && executable('xclip')
          let @" = system('xclip -o -selection clipboard')
        else
          let @" = system('/mnt/c/ProgramFiles/Win32Yank/win32yank.exe -o --lf')
        endif
     endif
     return a:mode
  endfunction
  map <expr> p Paste('p')
  map <expr> P Paste('P')
  " map Ctrl-c and Ctrl-x as expected
  " func! GetSelectedText()
  "   normal gv"xy
  "   let result = getreg("x")
  "   return result
  " endfunc
  " noremap <C-c> :call system(g:copy, GetSelectedText())<CR>
  " noremap <C-x> :call system(g:copy, GetSelectedText())<CR>gvx
endif

" -----------------------------------------------------------------------------
" Finding project root directories
" -----------------------------------------------------------------------------
let g:rooter_patterns = ['.git', 'package.json']

" -----------------------------------------------------------------------------
" Markdown / Asciidoc / Writing plugin configs
" -----------------------------------------------------------------------------
let g:vim_markdown_folding_disabled = 1
" let g:asciidoctor_extensions = ['asciidoctor-diagram']
" let g:asciidoctor_pdf_extensions = ['asciidoctor-diagram']
let g:asciidoctor_extensions = []
let g:asciidoctor_pdf_extensions = []
let g:asciidoctor_fenced_languages = ['python', 'c', 'javascript']
nmap <F9> :Asciidoctor2HTML<CR><CR>
imap <F9> :Asciidoctor2HTML<CR><CR>

let g:mkdp_auto_close = 0
let g:mkdp_open_to_the_world = 1
" let g:mkdp_open_ip = '192.168.1.1'
let g:mkdp_port = '5001'
let g:mkdp_markdown_css = ''
let g:mkdp_highlight_css = ''
" let g:mkdp_page_title = '-'
function! g:OpenBrowser(url)
  silent exe '!lemonade open 'a:url | redraw!
endfunction
let g:mkdp_browserfunc = 'g:OpenBrowser'
" let g:mkdp_filetypes = ['markdown', 'asciidoc', 'asciidoctor']

let g:goyo_width = '85'
let g:goyo_height = '90%'
let g:limelight_paragraph_span = 1

let g:hardtime_default_on = 1
let g:hardtime_showmsg = 1
let g:hardtime_ignore_buffer_patterns = [ "NERD.*" ]
let g:hardtime_ignore_quickfix = 1
let g:hardtime_allow_different_key = 1
let g:hardtime_maxcount = 2

let g:airline_powerline_fonts = 0
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
"let g:airline_left_sep = '»'
"let g:airline_left_sep = '▶'
"let g:airline_right_sep = '«'
"let g:airline_right_sep = '◀'
"let g:airline_symbols.colnr = ' ㏇:'
"let g:airline_symbols.colnr = ' ℅:'
"let g:airline_symbols.crypt = '🔒'
"let g:airline_symbols.linenr = '☰'
"let g:airline_symbols.linenr = ' ␊:'
"let g:airline_symbols.linenr = ' ␤:'
"let g:airline_symbols.linenr = '¶'
"let g:airline_symbols.maxlinenr = ''
"let g:airline_symbols.maxlinenr = '㏑'
""let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
"let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
"let g:airline_symbols.colnr = ' :'
let g:airline_symbols.colnr = ' |'
let g:airline_symbols.readonly = ''
"let g:airline_symbols.linenr = ' :'
let g:airline_symbols.linenr = ' '
"let g:airline_symbols.maxlinenr = '☰ '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty='⚡'
let g:airline_skip_empty_sections = 1

call airline#parts#define_function('pencil', 'PencilMode')
let g:airline_section_x = airline#section#create(['filetype', 'ale_error_count', ' ', 'pencil'])
let g:pencil#mode_indicators = {'hard': 'H', 'auto': 'A', 'soft': 'S', 'off': '',}

function! Prose()
  call pencil#init({'wrap': 'hard', 'autoformat': 1})
  set list
endfunction

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,asciidoc,asciidoctor call Prose()
augroup END

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" -----------------------------------------------------------------------------
" Linting Engine
" -----------------------------------------------------------------------------

" let the languageserver be run by coc
let g:ale_disable_lsp = 1
" leave the gutter always open to avoid the flicker
let g:ale_sign_column_always = 1
" on WSL always running the linter is too slow
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
" set to 0 to do not run linters on opening a file
let g:ale_lint_on_enter = 0
" set alex to run as globally installed command
" let g:ale_alex_use_global = 1
" let g:ale_alex_executable = '/tmp/fnm-shell-4391500/bin/alex'
" let g:ale_use_global_executables = 1
" au FileType asciidoctor let g:ale_linters = { 'asciidoctor': [ 'alex' ] }
" au FileType asciidoc let g:ale_linters = { 'asciidoctor': [ 'alex' ] }

au Filetype javascript set dictionary+=~/.vim/dict/node.dict
" au FileType javascript let g:ale_linters = { 'javascript': glob('.eslintrc*', '.;') != '' ? [ 'eslint', 'flow' ] : [ 'semistandard', 'standard', 'flow' ] }

" -----------------------------------------------------------------------------
" Completion Engine
" -----------------------------------------------------------------------------
let g:coc_disable_startup_warning = 1

if !empty(glob("${HOME}/.vim/plugged/coc.nvim"))

set hidden

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <C-d> <Plug>(coc-range-select)
xmap <silent> <C-d> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

endif

