" ____              _     _ _             _
"|  _ \  __ ___   _(_) __| ( )___  __   _(_)_ __ ___  _ __ ___
"| | | |/ _` \ \ / / |/ _` |// __| \ \ / / | '_ ` _ \| '__/ __|
"| |_| | (_| |\ V /| | (_| | \__ \  \ V /| | | | | | | | | (__
"|____/ \__,_| \_/ |_|\__,_| |___/   \_/ |_|_| |_| |_|_|  \___|

"you can expand and collapse sections with "za"

"essential settings {{{
	let mapleader = ','
	let maplocalleader = '\\'
	set number relativenumber
	set nocompatible
	set wrap
	syntax on
	filetype plugin on
	filetype on
	set clipboard+=unnamedplus
	set splitbelow splitright
	set background=dark
	set nohlsearch
	set encoding=utf-8

" Enable autocompletion:
	set wildmode=longest,list,full
	set mouse=nv
"easier split window navigation
	map <a-h> <C-w>h
	map <a-j> <C-w>j
	map <a-k> <C-w>k
	map <a-l> <C-w>l
"resize windows
	map <C-h> <C-w>>
	map <C-j> <C-w>+
	map <C-k> <C-w>-
	map <C-l> <C-w><
" Disables automatic commenting on newline:
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
"}}}

"Plugins {{{
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'szw/vim-maximizer'
Plug 'junegunn/goyo.vim'
Plug 'jreybert/vimagit'
Plug 'vimwiki/vimwiki'
Plug 'ap/vim-css-color'
Plug 'bling/vim-airline'
Plug 'kovetskiy/sxhkd-vim'
"Plug 'aquach/vim-mediawiki-editor'
"Plug 'preservim/nerdtree'
call plug#end()

"Plugin config {{{
	"colorscheme sxhkd
	"hi Normal guibg=NONE ctermbg=NONE
" Goyo plugin makes text more readable when writing prose:
	map <leader>f :Goyo \| set bg=light \| set linebreak<CR>
" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :setlocal spell! spelllang=en_us<CR>
" Nerd tree config*********
"	map <leader>n :NERDTreeToggle<CR>
"	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"    if has('nvim')
"        let NERDTreeBookmarksFile = stdpath('data') . '/NERDTreeBookmarks'
"    else
"        let NERDTreeBookmarksFile = '~/.vim' . '/NERDTreeBookmarks'
"    endif

"vimwiki
	let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
	map <leader>v :VimwikiIndex
	let g:vimwiki_list = [
				\ {'path': '~/Davids_wiki/vimwiki', 'syntax': 'markdown', 'ext': '.md'},
				\ {'path': '~/Davids_wiki/CODEX', 'syntax': 'markdown', 'ext': '.md'},
				\ {'path': '~/Davids_wiki/Computerisms', 'syntax': 'markdown', 'ext': '.md'},
				\ {'path': '~/Davids_wiki/Workout', 'syntax': 'markdown', 'ext': '.md'},
				\ {'path': '~/Davids_wiki/CTFN_wiki', 'syntax': 'markdown', 'ext': '.md'}
				\]
"make vfiles open properly
function! VimwikiLinkHandler(link)
    try
      execute '!$BROWSER  . a:link
      return 1
    catch
      echo "This can happen for a variety of reasons ..."
    endtry
    return 0
  endfunction

 function! VimwikiLinkHandler(link)
    " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
    "   1) [[vfile:~/Code/PythonProject/abc123.py]]
    "   2) [[vfile:./|Wiki Home]]
    let link = a:link
    if link =~# '^vfile:'
      let link = link[1:]
    else
      return 0
    endif
    let link_infos = vimwiki#base#resolve_link(link)
    if link_infos.filename == ''
      echomsg 'Vimwiki Error: Unable to resolve link!'
      return 0
    else
      exe 'tabnew ' . fnameescape(link_infos.filename)
      return 1
    endif
  endfunction

"vim-maximizer
nnoremap <silent><a-x> :MaximizerToggle<CR>
vnoremap <silent><a-x> :MaximizerToggle<CR>gv
inoremap <silent><a-x> <C-o>:MaximizerToggle<CR>

"MediaWiki Editor

let g:mediawiki_editor_url = 'wiki.computerisms.ca'
let g:mediawiki_editor_path = 'index.php'
let g:mediawiki_editor_uri_scheme = 'https'
"}}}

"}}}

"statusline {{{
" The general format is:
" %-0{minwid}.{maxwid}{item}
	set statusline=%.20F "Path to file
	set statusline+=\ -\  "Sparator
	set statusline+=FileType:\  "Label
	set statusline+=%y "Filetype of file
	set statusline+=%= "move everything after to right end of status line
	set statusline+=%2l/
	set statusline+=%04L "add a number to add a bit of padding to prevent glitchy jumping
	set statusline+=\ %p%%
"you can also use this format for left justified text: %-4L or padd with
"zeros with: %04l
"}}}

"mappings {{{
	noremap <leader>- ddp
	noremap <leader>_ ddkP
	nnoremap <leader><space> viw
	nnoremap H ^
	nnoremap L $
"edit and source vimrc
	nnoremap <leader>r :setlocal ro!<cr>
	nnoremap <leader>ev :vsplit $MYVIMRC<cr>
	nnoremap <leader>sv :source $MYVIMRC<cr>
"wrap last highlight in qoutes
	vnoremap <leader>" <esc>`<<esc>i"<esc>`>a"<esc>
"convert current word to UPPERCASE
	nnoremap <leader><c-u> <esc>viwU
" Replace all is aliased to S.
	nnoremap S :%s//g<Left><Left>
" Check file in shellcheck:
	map <leader>s :!clear && shellcheck %<CR>
" Open corresponding .pdf/.html or preview
	map <leader>p :!opout <c-r>%<CR><CR>

"operator based mappings
"page 35 of learn vimscript hard way
" - delete body of function
" onoremap b /return<cr>
" - inside paren regardless of current position in paren
" onoremap in( :<c-u>normal! f(vi<cr>
"}}}

"abbreviations {{{
"Common spelling errors {{{
iabbrev adn and
iabbrev nad and
iabbrev teh the
iabbrev waht what
iabbrev tehn then
iabbrev si is
iabbrev aer are
iabbrev wyh why
iabbrev yse yes
iabbrev yuo you
iabbrev ro or
iabbrev thier their
iabbrev tehm them
iabbrev beleive believe
iabbrev hlep help
iabbrev ehlp help
iabbrev acheive achieve
iabbrev freind friend
iabbrev excede exceed
iabbrev calender calendar
iabbrev allmost almost
iabbrev acceptible acceptable
iabbrev alot a lot
"}}}

"words that are too long {{{
iabbrev bc because
iabbrev ms Microsoft
iabbrev msof Microsoft Office
iabbrev yla Yukon Legislative Assembly
iabbrev ctfn Carcross Tagish First Nation
"}}}
iabbrev @@ david@computerisms.ca
iabbrev ssig -- <cr>David Ford<cr>david@computerisms.ca<cr>"That which hinders your task, Is your task"
"}}}

"autogroups {{{

"bash autocomplete --- {{{
augroup bash
	autocmd!
	autocmd FileType sh nnoremap <buffer> <localleader>c I#<esc>
	autocmd FileType sh iabbrev <buffer> iff if [[]]<left><left>
	autocmd FileType sh iabbrev <buffer> elif elif [[]]<left><left>
	autocmd FileType sh iabbrev <buffer> while while []<left>
	autocmd FileType sh iabbrev <buffer> doo do<lf><lf>done<up>
augroup END
"}}}

" Vimscript file settings ------------- {{{
augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

"markdown ----{{{
augroup markdown
	autocmd!
"note- you need to move over 2 because when you insert the 2 stars at start the visual field jump `> does not take that into account so you must correct it
	vnoremap <leader>b <esc>`<<esc>i**<esc>`>lla**<esc>
	"inside markdown header
	autocmd FileType md onoremap <buffer> ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
" upon opening .md file goto first link
	"autocmd BufWritePre *.md +/[
augroup END
"}}}


	autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown

" Save file as sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Enable Goyo by default for mutt writing
	autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
	autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=light
	autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
	autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>

" Automatically deletes all trailing whitespace and newlines at end of file on save.
	autocmd BufWritePre * %s/\s\+$//e
	autocmd BufWritepre * %s/\n\+\%$//e

" When shortcut files are updated, renew bash and ranger configs with new material:
	autocmd BufWritePost files,directories !shortcuts
" Run xrdb whenever Xdefaults or Xresources are updated.
	autocmd BufWritePost *Xresources,*Xdefaults !xrdb %
" Update binds when sxhkdrc is updated.
	autocmd BufWritePost *sxhkdrc !pkill -USR1 sxhkd

"}}}
