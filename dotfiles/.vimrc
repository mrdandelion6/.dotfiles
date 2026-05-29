let mapleader = " "
set backspace=indent,eol,start
syntax on
nnoremap c "_c
nnoremap C "_C
nnoremap x "_x
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" remove trailing whitespace automatically when saving
autocmd BufWritePre * %s/\s\+$//e

" show trailing spaces
set list
set listchars=trail:·
highlight SpecialKey ctermfg=7 guifg=#c0c0c0

" ===== COLEMAK LAYOUT SUPPORT =====
" persist layout settings here
let s:settings_dir = expand('$HOME/.config/editor')
let s:layout_file = s:settings_dir . '/layout'
call mkdir(s:settings_dir, 'p')

" function to read layout from settings file
function! ReadLayout()
    if filereadable(s:layout_file)
        return trim(join(readfile(s:layout_file), "\n"))
    endif
    return 'qwerty'
endfunction

" function to update layout file
function! UpdateLayout(new_layout)
    call mkdir(s:settings_dir, 'p')
    call writefile([a:new_layout], s:layout_file)
endfunction

" function to apply colemak remaps
function! ApplyColemakRemaps()
    " movement keys - colemak: k=left, n=down, e=up, i=right
    nnoremap k h
    nnoremap n j
    nnoremap e k
    nnoremap i l
    nnoremap K H
    nnoremap N J
    nnoremap E K
    nnoremap I L

    " visual mode
    vnoremap k h
    vnoremap n j
    vnoremap e k
    vnoremap i l
    vnoremap K H
    vnoremap N J
    vnoremap E K
    vnoremap I L

    " remap displaced keys (not symmetrical)
    nnoremap h n
    nnoremap j e
    nnoremap l i
    nnoremap H N
    nnoremap J E
    nnoremap L I

    vnoremap h n
    vnoremap j e
    vnoremap l i
    vnoremap H N
    vnoremap J E
    vnoremap L I

    " buffer jumping
    silent! nunmap <C-h>
    silent! nunmap <C-j>
    silent! nunmap <C-k>
    silent! nunmap <C-l>

    nnoremap <C-k> <C-w>h
    nnoremap <C-n> <C-w>j
    nnoremap <C-e> <C-w>k
    nnoremap <C-i> <C-w>l

    let g:current_layout = 'colemak'
endfunction

" function to remove colemak remaps (restore qwerty)
function! RemoveColemakRemaps()
    " remove all the custom mappings
    silent! nunmap k
    silent! nunmap n
    silent! nunmap e
    silent! nunmap i
    silent! nunmap K
    silent! nunmap N
    silent! nunmap E
    silent! nunmap I
    silent! nunmap h
    silent! nunmap j
    silent! nunmap l
    silent! nunmap H
    silent! nunmap J
    silent! nunmap L

    " remove visual mode mappings
    silent! vunmap k
    silent! vunmap n
    silent! vunmap e
    silent! vunmap i
    silent! vunmap K
    silent! vunmap N
    silent! vunmap E
    silent! vunmap I
    silent! vunmap h
    silent! vunmap j
    silent! vunmap l
    silent! vunmap H
    silent! vunmap J
    silent! vunmap L

    " buffer jumping
    silent! nunmap <C-k>
    silent! nunmap <C-n>
    silent! nunmap <C-e>
    silent! nunmap <C-i>

    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    let g:current_layout = 'qwerty'
endfunction

" function to toggle between colemak and qwerty
function! ToggleLayout()
    if get(g:, 'current_layout', 'qwerty') == 'qwerty'
        call ApplyColemakRemaps()
        call UpdateLayout('colemak')
        echo "Using Colemak-DH"
    else
        call RemoveColemakRemaps()
        call UpdateLayout('qwerty')
        echo "Using QWERTY"
    endif
endfunction

" initialize layout based on settings file
function! InitializeLayout()
    let layout = ReadLayout()

    if layout == 'colemak'
        call ApplyColemakRemaps()
        echo "Using Colemak-DH"
    else
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l
        let g:current_layout = 'qwerty'
        echo "Using QWERTY"
    endif
endfunction

" key mapping for toggle
nnoremap <Leader>tc :call ToggleLayout()<CR>

" initialize layout when vim starts
autocmd VimEnter * call InitializeLayout()

" ===== TERMINAL SETTINGS =====
" set default shell to powershell
if has('win32') || has('win64')
    set shell=powershell.exe
    set shellcmdflag=-NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    set shellquote=\"
    set shellxquote=
endif

" override :term to open vertical terminal
command! -nargs=* Term :botright vertical terminal <args>
cnoreabbrev term Term

" allow :q and :qa to quit even with running terminal jobs
set confirm
autocmd TerminalOpen * set bufhidden=hide

" double escape to exit terminal mode to normal mode
tnoremap <Esc><Esc> <C-\><C-n>

" ===== CLIPBOARD BACKEND =====
if has('clipboard')
    set clipboard=unnamed,unnamedplus
else
    set clipboard=
endif

if executable('wl-copy') && executable('wl-paste')
    let s:clip_copy_cmd  = 'wl-copy'
    let s:clip_paste_cmd = 'wl-paste --no-newline'
elseif executable('xclip')
    let s:clip_copy_cmd  = 'xclip -selection clipboard'
    let s:clip_paste_cmd = 'xclip -selection clipboard -o'
else
    let s:clip_copy_cmd  = ''
    let s:clip_paste_cmd = ''
endif

if has('clipboard')
    set clipboard=unnamed,unnamedplus
else
    set clipboard=
endif

function! s:SystemPaste()
    if empty(s:clip_paste_cmd)
        echo "No clipboard backend found"
        return
    endif

    let l:clip = system(s:clip_paste_cmd)
    if v:shell_error
        echo "Clipboard paste failed"
        return
    endif

    let l:save_reg = getreg('"')
    let l:save_type = getregtype('"')
    call setreg('"', l:clip)
    normal! ""p
    call setreg('"', l:save_reg, l:save_type)
endfunction

function! s:CopyLineToSystemClipboard()
    if empty(s:clip_copy_cmd)
        echo "No clipboard backend found"
        return
    endif

    call system(s:clip_copy_cmd, getline('.') . "\n")
    if v:shell_error
        echo "Clipboard copy failed"
    endif
endfunction

command! SysPaste call <SID>SystemPaste()
nnoremap <Leader>p :SysPaste<CR>
nnoremap <Leader>yy :call <SID>CopyLineToSystemClipboard()<CR>

" for ssh copying
function! s:OSC52Copy(text)
  let b64 = system('base64 -w 0', a:text)
  let b64 = substitute(b64, '\n', '', 'g')
  let osc = "\033]52;c;" . b64 . "\007"
  if has('nvim')
    call chansend(v:stderr, osc)
  else
    " vim compatible — write directly to terminal
    silent! call writefile([osc], '/dev/tty', 'b')
  endif
endfunction

autocmd TextYankPost * if v:event.operator ==# 'y' | call s:OSC52Copy(join(v:event.regcontents, "\n")) | endif
