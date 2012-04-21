"=============================================================================
" 基本設定 : {{{

" ファイルタイププラグイン
filetype plugin on

" ファイルタイプインデント
filetype indent on

" augroup設定
augroup MyAutoCmd
    autocmd!
augroup END

" windows環境用変数
let s:iswin = has('win32') || has('win64')

" mac環境用変数
let s:ismac = has('mac')

" .vimとvimfilesの違いを吸収する
if s:iswin
    let $DOTVIM = $HOME."/vimfiles"
else
    let $DOTVIM = $HOME."/.vim"
endif

" vimrcを開く
nnoremap <silent>vv :<C-u>e $MYVIMRC<CR>

" vimrc変更時は自動で再読み込み
autocmd MyAutoCmd BufWritePost $MYVIMRC source $MYVIMRC

" 起動時にvimrcを開く
autocmd MyAutoCmd VimEnter * nested if @% == '' | edit $MYVIMRC | endif

" }}}
"=============================================================================
" 文字コード設定 : {{{

" 内部文字コード
set encoding=utf-8

" ターミナルエンコーディング
if has('gui_running') && s:iswin
    set termencoding=cp932
endif

" 文字コード判別リスト
if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213,euc-jp'
        let s:enc_jis = 'iso-2022-jp-3'
    endif
    let &fileencodings = 'ucs-bom'
    if &encoding !=# 'utf-8'
        let &fileencodings = &fileencodings . ',' . 'ucs-2le'
        let &fileencodings = &fileencodings . ',' . 'ucs-2'
    endif
    let &fileencodings = &fileencodings . ',' . s:enc_jis
    if &encoding ==# 'utf-8'
        let &fileencodings = &fileencodings . ',' . s:enc_euc
        let &fileencodings = &fileencodings . ',' . 'cp932'
    elseif &encoding =~# '^euc-\%(jp\|jisx0213\)$'
        let &encoding = s:enc_euc
        let &fileencodings = &fileencodings . ',' . 'utf-8'
        let &fileencodings = &fileencodings . ',' . 'cp932'
    else
        let &fileencodings = &fileencodings . ',' . 'utf-8'
        let &fileencodings = &fileencodings . ',' . s:enc_euc
    endif
    let &fileencodings = &fileencodings . ',' . &encoding
    unlet s:enc_euc
    unlet s:enc_jis
endif

" 改行コード判別リスト
set fileformats=unix,dos,mac

" 新規バッファ作成時
autocmd MyAutoCmd BufNewFile * setlocal fileencoding=utf8 fileformat=unix

" 各種文字コードで開き直す
command! -bang -bar -complete=file -nargs=? Utf8 edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? Jis edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? Sjis edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Euc edit<bang> ++enc=euc-jp <args>

" 各種改行コードで開き直す
command! -bang -bar -complete=file -nargs=? Unix edit<bang> ++fileformat=unix <args>
command! -bang -bar -complete=file -nargs=? Dos edit<bang> ++fileformat=dos <args>
command! -bang -bar -complete=file -nargs=? Mac edit<bang> ++fileformat=mac <args>

" }}}
"=============================================================================
" 表示設定 : {{{

" 表示メッセージロケール
language message C

" シンタックスON
if !exists('syntax_on')
    syntax enable
endif

" シンタックス有効桁数
set synmaxcol=1000

" シンタックスON/OFF切り替え
nnoremap <expr><F3> exists('syntax_on') ? ":\<C-u>syntax off\<CR>" : ":\<C-u>syntax enable\<CR>"

" 全画面表示
if s:iswin
    autocmd MyAutoCmd GUIEnter * FullScreen
else
    autocmd MyAutoCmd GUIEnter * set columns=1000 lines=1000
endif

" GUIオプション
set guioptions&
set guioptions-=m
set guioptions-=T
set guioptions+=b

" GUIフォント
if s:iswin
    autocmd MyAutoCmd GUIEnter * set guifont=MS_Gothic:h10:cSHIFTJIS
else
    autocmd MyAutoCmd GUIEnter * set guifont=Osaka-Mono:h14
endif

" カラースキーム
if !exists('g:colors_name')
    autocmd MyAutoCmd GUIEnter * colorscheme nevfn
endif

" 半透明
if has('gui_running')
    if s:iswin
        autocmd MyAutoCmd GUIEnter * set transparency=220
    else
        set transparency=10
    endif
endif

" ビジュアルベル
set visualbell

" ステータスラインを常に表示
set laststatus=2

" ステータスライン表示内容
let &statusline = ''
let &statusline .= '%{expand("%:t")}'
let &statusline .= '%h%w%m%r'
let &statusline .= ' (%<%{expand("%:p:~:h")}) '
let &statusline .= '%='
let &statusline .= '[HEX:%B][R:%l][C:%c]'
let &statusline .= '%y'
let &statusline .= '[%{&fileencoding != "" ? &fileencoding : &encoding}]'
let &statusline .= '%{&bomb ? "[BOM]" : ""}'
let &statusline .= '[%{&fileformat}]'

" 現在のモードを表示
set showmode

" 相対行番号を表示
set relativenumber

" 行を折り返して表示
set wrap

" 折り返された行の先頭に表示する文字列
let &showbreak = '+++ '

" 現在行のハイライト
set cursorline
autocmd MyAutoCmd WinLeave * set nocursorline
autocmd MyAutoCmd WinEnter,BufRead * set cursorline

" 括弧の対応表示を行う
set showmatch

" <TAB>、行末スペース、スクロール中の行頭文字の可視化
set list
set listchars=tab:>\ ,trail:-,nbsp:%,precedes:<

" 全角スペースを視覚化
autocmd MyAutoCmd VimEnter,BufRead,WinEnter,WinLeave * match IdeographicSpace /　/
if (has('gui_running'))
    autocmd MyAutoCmd GUIEnter * highlight IdeographicSpace term=underline ctermbg=Gray guibg=Gray50
else
    highlight IdeographicSpace term=underline ctermbg=Gray guibg=Gray50
endif

" 全角文字表示幅
if exists('&ambiwidth')
    set ambiwidth=double
endif

" 全角入力時のカーソルの色を変更
autocmd MyAutoCmd ColorScheme * highlight CursorIM guifg=#000000 guibg=#cc9999 gui=NONE

" インサートモード時のステータスバーの色を変更
let g:hi_insert = 'hi StatusLine guibg=#1f001f guifg=Tomato cterm=NONE ctermfg=White ctermbg=LightRed'
if has('syntax')
    autocmd MyAutoCmd InsertEnter * call s:StatusLine('Enter')
    autocmd MyAutoCmd InsertLeave * call s:StatusLine('Leave')
endif
let s:slhlcmd = ''
function! s:StatusLine(mode)
    if a:mode == 'Enter'
        silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
        silent execute g:hi_insert
    else
        highlight clear StatusLine
        silent execute s:slhlcmd
    endif
endfunction
function! s:GetHighlight(hi)
    redir => hl
    execute 'highlight ' . a:hi
    redir END
    let hl = substitute(hl, '[\r\n]', '', 'g')
    let hl = substitute(hl, 'xxx', '', '')
    return hl
endfunction

" }}}
"=============================================================================
" インデント設定 : {{{

" <TAB>は空白を使用
set expandtab

" <TAB>が対応する空白量
set tabstop=8

" <TAB>で挿入される空白量
set softtabstop=4

" インデントの移動幅
set shiftwidth=4

" 行頭の余白内で<TAB>を打ち込むと'shiftwidth'の数だけインデントする
set smarttab

" 新しい行のインデントを現在行と同じにする
set autoindent

" 新しい行を作成したときに高度な自動インデントを行う
set smartindent

" }}}
"=============================================================================
" 入力設定 : {{{

" タイムアウトあり
set timeout

" 入力待ち時間
set timeoutlen=10000

" <Leader>
let mapleader = ","

" ;と:を入れ替え
noremap ; :
noremap : ;

" 全てのキーマップを表示
command! -nargs=* -complete=mapping AllMaps map <args> | map! <args> | lmap <args>

" IME状態を保存しない
if has('multi_byte_ime')
    set iminsert=0
    set imsearch=0
    inoremap <silent><ESC> <ESC>
endif

" xを汎用キー化
noremap x <Nop>

" 日時の短縮入力
iabbrev *dt* <C-r>=strftime("%Y/%m/%d %H:%M:%S")<CR><C-r>=<SID>Eatchar('\s')<CR>
iabbrev *d* <C-r>=strftime("%Y/%m/%d")<CR><C-r>=<SID>Eatchar('\s')<CR>
iabbrev *t* <C-r>=strftime("%H:%M:%S")<CR><C-r>=<SID>Eatchar('\s')<CR>
function! s:Eatchar(pattern)
    let c = nr2char(getchar(0))
    return (c =~ a:pattern) ? '' : c
endfunction

" テキストオブジェクト簡易入力
xnoremap ia i<
onoremap ia i<
xnoremap aa a<
onoremap aa a<
xnoremap ir i[
onoremap ir i[
xnoremap ar a[
onoremap ar a[

" 番号付きリストを作成
nnoremap <silent>xl :<C-u>call <SID>MakeOrderedList()<CR>
function! s:MakeOrderedList()
    let current = line('.')
    for i in range(1, v:count)
        put =i . '. '
    endfor
    execute 'normal!' current + 1 . 'G'
endfunction

" phpにて$this->を@で入力
autocmd MyAutoCmd FileType php inoremap <expr><buffer> @ <SID>at()
function! s:at()
    let syntax = synstack(line('.'), col('.'))
    let name = empty(syntax) ? '' : synIDattr(syntax[-1], "name")
    return name =~# 'String\|Comment\|None' ? '@' : '$this->'
endfunction

" 改行時に対応する括弧を補完
inoremap <expr><CR> <SID>ExCr()
function! s:ExCr()
    if col('.') != col('$')
        return "\<CR>"
    endif
    let l = getline('.')
    if l =~ '{$'
        return "\<CR>}\<Up>\<End>\<CR>"
    elseif l =~ '($'
        return "\<CR>)\<Up>\<End>\<CR>"
    elseif l =~ '[$'
        return "\<CR>]\<Up>\<End>\<CR>"
    else
        return "\<CR>"
    endif
endfunction

" }}}
"=============================================================================
" 編集設定 : {{{

" バックスペース対象
set backspace=indent,eol,start

" Yの動作をDやCと同じにする
map Y y$

" 空行を挿入
nnoremap <silent><S-CR> :<C-u>call append('.', '')<CR>j

" ノーマルモードでの改行
nnoremap <C-CR> i<CR><ESC>

" コメントを継続しない
autocmd MyAutoCmd FileType * setlocal formatoptions& formatoptions-=o formatoptions-=r

" インサートモード中の履歴保存
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w> <C-g>u<C-w>

" ^Mを取り除く
command! RemoveCr :silent! normal! :%s/<C-v><CR>//g<CR>:nohlsearch<CR>``

" 行末のスペースを取り除く
command! RemoveEolSpace :silent! normal! :%s/ \+$//g<CR>:nohlsearch<CR>``

" 空行を取り除く
command! RemoveBlankLine :silent! normal! :%s/^\n//g<CR>:nohlsearch<CR>``

" 手動コメントアウト
noremap [Comment] <Nop>
map gc [Comment]
noremap <silent>[Comment]c :call <SID>ToggleComment('// ', '')<CR>
noremap <silent>[Comment]h :call <SID>ToggleComment('<!-- ', ' -->')<CR>
noremap <silent>[Comment]i :call <SID>ToggleComment('; ', '')<CR>
noremap <silent>[Comment]p :call <SID>ToggleComment('# ', '')<CR>
noremap <silent>[Comment]s :call <SID>ToggleComment('-- ', '')<CR>
noremap <silent>[Comment]v :call <SID>ToggleComment('" ', '')<CR>
function! s:ToggleComment(cs, ce) range
    let current = a:firstline
    while (current <= a:lastline)
        let line = getline(current)
        if strpart(line, match(line, "[^ \t]"), strlen(a:cs)) == a:cs
            execute 'normal! ^' . strlen(a:cs) . 'x'
        else
            execute 'normal! I' . a:cs
        endif
        if !empty(a:ce)
            if strlen(line) == strridx(line, a:ce) + strlen(a:ce)
                execute 'normal! $v' . (strlen(a:ce) - 1) . 'hd'
            else
                execute 'normal! A' . a:ce
            endif
        endif
        normal! j
        let current = current + 1
    endwhile
    normal! k
endfunction

" undo情報を破棄
nnoremap <silent>xU :<C-u>call <SID>DropUndoInfo()<CR>
function! s:DropUndoInfo()
    if &modified
        echoerr "This buffer has been modified!"
        return
    endif
    let l:old_undolevels = &undolevels
    set undolevels=-1
    execute "normal! aa\<BS>\<ESC>"
    let &modified = 0
    let &undolevels = l:old_undolevels
endfunction

" }}}
"=============================================================================
" 移動設定 : {{{

" 10行移動
noremap <C-j> 10j
noremap <C-k> 10k

" wの動作をeに変更
noremap w e
noremap W E

" カーソルを行頭、行末で止まらないようにする
set whichwrap=h,l,[,],<,>

" ビジュアルモード時の$は改行まで移動しない
set selection=old

" 対応移動ペア
set matchpairs=(:),{:},[:],<:>

" カーソルの上または下に表示する最低行数
set scrolloff=5

" スクロール時に列を維持する
set nostartofline

" 最後に編集した内容を選択
nnoremap gm `[v`]
vnoremap gm :<C-u>normal gm<CR>
onoremap gm :<C-u>normal gm<CR>

" phpにてlast_patternを変更しない関数移動
autocmd MyAutoCmd FileType php call <SID>RemapPHPSectionJump()
function! s:RemapPHPSectionJump()
    let function = '\(abstract\s\+\|final\s\+\|private\s\+\|protected\s\+\|public\s\+\|static\s\+\)*function'
    let class = '\(abstract\s\+\|final\s\+\)*class'
    let interface = 'interface'
    let section = '\(.*\%#\)\@!\_^\s*\zs\('.function.'\|'.class.'\|'.interface.'\)'
    exe "nno <buffer> <silent> [[ :<C-u>call search('" . escape(section, '|') . "', 'b')<CR>"
    exe "nno <buffer> <silent> ]] :<C-u>call search('" . escape(section, '|') . "')<CR>"
    exe "ono <buffer> <silent> [[ :<C-u>call search('" . escape(section, '|') . "', 'b')<CR>"
    exe "ono <buffer> <silent> ]] :<C-u>call search('" . escape(section, '|') . "')<CR>"
endfunction

" }}}
"=============================================================================
" 検索設定 : {{{

" 検索パターンにマッチした箇所を強調表示
set hlsearch

" インクリメンタル検索
set incsearch

" 検索文字列の大文字小文字を区別しない
set ignorecase

" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase

" 循環検索
set wrapscan

" *による検索時に初回は移動しない
nnoremap * g*N

" ビジュアルモード時の*検索
vnoremap <silent>* "zy:let @/ = @z<CR>:set hlsearch<CR>

" '/'と'?'を自動エスケープ
cnoremap <expr>/  getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr>?  getcmdtype() == '?' ? '\?' : '?'

" 選択範囲内の検索
vnoremap <silent>/ :<C-u>call <SID>RangeSearch('/')<CR>
vnoremap <silent>? :<C-u>call <SID>RangeSearch('?')<CR>
function! s:RangeSearch(d)
    let s = input(a:d)
    if strlen(s) > 0
        let s = a:d . '\%V' . s . "\<CR>"
        call feedkeys(s, 'n')
    endif
endfunction

" <ESC>でハイライト消去
nnoremap <silent><ESC> :<C-u>nohlsearch<CR>

" }}}
"=============================================================================
" コマンド設定 : {{{

" コマンド補完候補を表示
set wildmenu

" 補完モード
set wildmode=full

" zsh風履歴検索
cnoremap <C-p> <Up>
cnoremap <Up> <C-p>
cnoremap <C-n> <Down>
cnoremap <Down> <C-n>

" コマンドライン行数
autocmd MyAutoCmd GUIEnter * set cmdheight=1

" 入力中コマンドを表示
set showcmd

" コマンドの出力を別ウィンドウで開く
command! -nargs=+ -complete=command Capture silent call <SID>CmdCapture(<q-args>)
function! s:CmdCapture(cmd)
    redir => result
    execute a:cmd
    redir END
    new
    setlocal bufhidden=unload nobuflisted buftype=nofile noswapfile
    file `='Capture: ' . a:cmd`
    call setline(1, split(substitute(result, '^\n\+', '', ''), '\n'))
endfunction

" ファイルパス簡易入力
cnoremap <C-g>f <C-r>=expand('%:t')<CR>
cnoremap <C-g>d <C-r>=expand('%:p:h')<CR>/

" }}}
"=============================================================================
" ファイル設定 : {{{

" ファイルパス区切り文字
if s:iswin
    " set shellslash
endif

" 拡張子毎のfiletype指定
autocmd MyAutoCmd BufRead,BufNewFile *.ctp set filetype=php
autocmd MyAutoCmd BufRead,BufNewFile *.jade set filetype=jade

" ファイルタイプ指定
nnoremap xof :set filetype=

" 編集中ファイルのリネーム
command! -nargs=1 -complete=file Rename file <args> | w | call delete(expand('#'))

" ジャンクファイル
command! -nargs=0 JunkFile call s:OpenJunkFile()
function! s:OpenJunkFile()
    let l:junk_dir = $HOME . '/.vim_junk' . strftime('/%Y/%m')
    if !isdirectory(l:junk_dir)
        call mkdir(l:junk_dir, 'p')
    endif
    let l:filename = input('Junk Code: ', l:junk_dir . strftime('/%Y-%m-%d-%H%M%S.'))
    if l:filename != ''
        execute 'edit ' . l:filename
    endif
endfunction

" gfは別ウィンドウで開く
nnoremap gf <C-w>F
xnoremap gf <C-w>F

" ファイル/パス名判定文字
if s:iswin
    set isfname&
    set isfname-=:
endif

" php構文チェック
command! -nargs=0 PHPl !php -l %

" 現在のパスを初期表示して:edit
nnoremap O :edit <C-r>=expand("%:p")<CR>
nnoremap T :tabedit <C-r>=expand("%:p")<CR>

" }}}
"=============================================================================
" バッファ設定 : {{{

" ファイルを切り替える際に自動で隠す
set hidden

" 他のプログラムで書き換えられたら自動で再読み込み
set autoread

" バッファを開く度カレントディレクトリを変更
autocmd MyAutoCmd BufEnter * execute "lcd " . expand("%:p:h")

" カレントバッファの情報を表示
nnoremap <silent><C-g> :<C-u>call <SID>BufInfo()<CR>
function! s:BufInfo()
    echo '[ fpath ] ' . expand('%:p')
    echo '[ bufnr ] ' . bufnr('%')
    if filereadable(expand('%'))
        echo '[ mtime ] ' . strftime('%Y-%m-%d %H:%M:%S', getftime(expand('%')))
    endif
    echo '[ fline ] ' . (line('$')) . ' lines'
    echo '[ fsize ] ' . (line2byte(line('$') + 1) - 1) . ' bytes'
endfunction

" ウィンドウのレイアウトを崩さずにバッファを閉じる
nnoremap <silent><BS> :<C-u>call <SID>BdKeepWin()<CR>
function! s:BdKeepWin()
    if bufname('%') != ''
        let l:curbuf = bufnr('%')
        let l:altbuf = bufnr('#')
        let l:buflist = filter(range(1, bufnr('$')), 'buflisted(v:val) && l:curbuf != v:val')
        if len(l:buflist) == 0
            enew
        elseif l:curbuf != l:altbuf
            execute 'buffer ' . (buflisted(l:altbuf) ? l:altbuf : l:buflist[0])
        else
            execute 'buffer ' . l:buflist[0]
        endif
        if buflisted(l:curbuf) && bufwinnr(l:curbuf) == -1
            execute 'bdelete ' . l:curbuf
        endif
    endif
endfunction

" 現在のバッファを削除
nnoremap <silent><S-BS> :<C-u>bwipeout!<CR>

" 全バッファを削除
command! -nargs=0 AllWipeout call <SID>AllWipeout()
function! s:AllWipeout()
    for i in range(1, bufnr('$'))
        if bufexists(i)
            execute 'bwipeout ' . i
        endif
    endfor
endfunction

" }}}
"=============================================================================
" ウィンドウ設定 : {{{

" 自動調整を行う
set equalalways

" サイズ調整は幅と高さ
set eadirection=both

" ウィンドウを最大化
nnoremap <C-w>o <C-w>_<C-w>\|

" 他のウィンドウを閉じる
nnoremap <C-w>O <C-w>o

" プレビューウィンドウの高さ
set previewheight=15

" プレビューウィンドウを閉じる
nnoremap <silent><C-w>z :<C-u>call <SID>closePreviewWindow()<CR>
function! s:closePreviewWindow()
    if &previewwindow
        execute "normal! \<C-w>p"
    endif
    execute "normal! \<C-w>z"
endfunction

" }}}
"=============================================================================
" タブ設定 : {{{

" タブバーは常に表示
set showtabline=2

" ラベル表示内容
autocmd MyAutoCmd GUIEnter * set guitablabel=%t

" タプを作成
nnoremap <C-t> :<C-u>99tabnew<CR>

" 次/前のタプ
nnoremap <C-n> gt
nnoremap <C-p> gT

" タプを閉じる
nnoremap dt :<C-u>tabclose<CR>

" }}}
"=============================================================================
" 差分設定 : {{{

" 差分モードオプション
set diffopt=filler

" 差分表示用タブを作成
command! DiffNew silent call <SID>DiffNew()
function! s:DiffNew()
    99tabnew
    setlocal bufhidden=unload nobuflisted buftype=nofile noswapfile
    file [Diff Right]
    vnew
    setlocal bufhidden=unload nobuflisted buftype=nofile noswapfile
    file [Diff Left]
    windo diffthis
endfunction

" 差分情報を更新
nnoremap <silent>du :<C-u>call <SID>DiffUpdate()<CR>
function! s:DiffUpdate()
    if &diff
        diffupdate
    else
        echohl ErrorMsg | echo 'E99: Current buffer is not in diff mode' | echohl None
    endif
endfunction

" }}}
"=============================================================================
" 折畳設定 : {{{

" 折畳有効
set foldenable

" 折畳方法
set foldmethod=marker

" 折畳範囲表示幅
set foldcolumn=1

" l/hで開閉
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'

" }}}
"=============================================================================
" レジスタ設定 : {{{

" 内容確認
nnoremap R :<C-u>registers<CR>

" クリップボードと連携
set clipboard&
set clipboard+=unnamed

" }}}
"=============================================================================
" マーク設定 : {{{

" 起動時に初期化を行う
autocmd MyAutoCmd VimEnter * delmarks!

" 基本マップ
nnoremap [Mark] <Nop>
nmap m [Mark]

" 現在位置をマーク
nnoremap <silent>[Mark]m :<C-u>call <SID>AutoMark()<CR>
if !exists('g:marks_pos')
    let g:marks_char = [
    \     'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    \     'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    \ ]
endif
function! s:AutoMark()
    if !exists('b:marks_current_pos') || (b:marks_current_pos == len(g:marks_char) - 1)
        let b:marks_current_pos = 0
    else
        let b:marks_current_pos = b:marks_current_pos + 1
    endif
    execute 'mark' g:marks_char[b:marks_current_pos]
    echo 'marked' g:marks_char[b:marks_current_pos]
endfunction

" 次/前のマーク
nnoremap [Mark]n ]'
nnoremap [Mark]p ['

" 一覧表示
nnoremap [Mark]l :<C-u>marks<CR>

" }}}
"=============================================================================
" タグ設定 : {{{

" タグファイル指定
if has('path_extra')
    set tags=.tags;
endif

" 基本マップ
nnoremap [Tag] <Nop>
nmap t [Tag]

" タグジャンプ
nnoremap [Tag]t <C-]>

" 進む/戻る
nnoremap [Tag]n :<C-u>tag<CR>
nnoremap [Tag]p :<C-u>pop<CR>

" 別ウィンドウで開く
nnoremap [Tag]o <C-w>]

" プレビューウィンドウで開く
nnoremap [Tag]O <C-w>}<C-w>P

" プレビューウィンドウを閉じる
nmap [Tag]z <C-w>z

" }}}
"=============================================================================
" バックアップ設定 : {{{

" バックアップファイル作成
set backup
set backupdir=$DOTVIM/tmp/backup

" スワップファイル作成
set swapfile
set directory=$DOTVIM/tmp/swap

" }}}
"=============================================================================
" その他設定 : {{{

" 強制全保存終了を無効化
nnoremap ZZ <Nop>

" オプションのトグル
nnoremap [Option] <Nop>
nmap xo [Option]
nnoremap <silent>[Option]n :<C-u>call <SID>ToggleOption('number')<CR>
nnoremap <silent>[Option]r :<C-u>call <SID>ToggleOption('readonly')<CR>
nnoremap <silent>[Option]w :<C-u>call <SID>ToggleOption('wrap')<CR>
nnoremap <silent>[Option]/ :<C-u>call <SID>ToggleOption('wrapscan')<CR>
function! s:ToggleOption(option)
    if has_key(g:toggle_option_extra, a:option)
        for e in g:toggle_option_extra[a:option]
            if exists('+' . e) && eval("&" . e) == 0
                execute 'setlocal' e . '!' e . '?'
                return
            endif
        endfor
    elseif exists('+' . a:option)
        execute 'setlocal' a:option . '!' a:option . '?'
    endif
endfunction
let g:toggle_option_extra = {
\     'number' : ['number', 'relativenumber']
\ }

" vimスカウター
command! -bar -bang -nargs=? -complete=file Scouter echo s:Scouter(empty(<q-args>) ? $MYVIMRC : expand(<q-args>), <bang>0)
command! -bar -bang -nargs=? -complete=file GScouter echo s:Scouter(empty(<q-args>) ? $MYGVIMRC : expand(<q-args>), <bang>0)
function! s:Scouter(file, ...)
    let pat = '^\s*$\|^\s*"'
    let lines = readfile(a:file)
    if !a:0 || !a:1
        let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
    endif
    return len(filter(lines,'v:val !~ pat'))
endfunction

" }}}
"=============================================================================
" プラグイン設定 : {{{

" 初期化
if has('vim_starting')
    filetype off
    set runtimepath+=$DOTVIM/bundle/neobundle.vim
    call neobundle#rc(expand($DOTVIM . '/bundle'))
    filetype plugin on
    filetype indent on
endif

" from Github
NeoBundle 'git://github.com/akiyan/vim-textobj-php.git'
NeoBundle 'git://github.com/anyakichi/vim-surround.git'
NeoBundle 'git://github.com/digitaltoad/vim-jade.git'
NeoBundle 'git://github.com/h1mesuke/unite-outline.git'
NeoBundle 'git://github.com/h1mesuke/vim-alignta.git'
NeoBundle 'git://github.com/kana/vim-operator-replace.git'
NeoBundle 'git://github.com/kana/vim-operator-user.git'
NeoBundle 'git://github.com/kana/vim-smartinput.git'
NeoBundle 'git://github.com/kana/vim-submode.git'
NeoBundle 'git://github.com/kana/vim-textobj-indent.git'
NeoBundle 'git://github.com/kana/vim-textobj-entire.git'
NeoBundle 'git://github.com/kana/vim-textobj-lastpat.git'
NeoBundle 'git://github.com/kana/vim-textobj-line.git'
NeoBundle 'git://github.com/kana/vim-textobj-syntax.git'
NeoBundle 'git://github.com/kana/vim-textobj-user.git'
NeoBundle 'git://github.com/mattn/calendar-vim.git'
NeoBundle 'git://github.com/mattn/mahjong-vim.git'
NeoBundle 'git://github.com/mattn/webapi-vim.git'
NeoBundle 'git://github.com/mattn/zencoding-vim.git'
NeoBundle 'git://github.com/saihoooooooo/vim-auto-colorscheme.git'
NeoBundle 'git://github.com/saihoooooooo/vim-textobj-space.git'
NeoBundle 'git://github.com/Shougo/unite.vim.git'
NeoBundle 'git://github.com/Shougo/neobundle.vim.git'
NeoBundle 'git://github.com/Shougo/neocomplcache.git'
NeoBundle 'git://github.com/Shougo/neocomplcache-snippets-complete.git'
NeoBundle 'git://github.com/Shougo/vimfiler.git'
NeoBundle 'git://github.com/Shougo/vimproc.git'
NeoBundle 'git://github.com/Shougo/vimshell.git'
NeoBundle 'git://github.com/thinca/vim-textobj-between.git'
NeoBundle 'git://github.com/thinca/vim-quickrun.git'
NeoBundle 'git://github.com/thinca/vim-ref.git'
NeoBundle 'git://github.com/thinca/vim-unite-history.git'
NeoBundle 'git://github.com/tpope/vim-repeat.git'
NeoBundle 'git://github.com/tsaleh/vim-matchit.git'
NeoBundle 'git://github.com/tsukkee/unite-help.git'
NeoBundle 'git://github.com/tyru/open-browser.vim.git'
NeoBundle 'git://github.com/tyru/operator-camelize.vim.git'
NeoBundle 'git://github.com/vim-scripts/TwitVim.git'
NeoBundle 'git://github.com/vim-scripts/vcscommand.vim.git'

" from vim-script
NeoBundle 'BlackSea'
NeoBundle 'nevfn'

"=============================================================================
" vim-textobj-php : {{{

" 設定なし

" }}}
"=============================================================================
" vim-surround : {{{

" キーマップ
nmap s <Plug>Ysurround
nmap ss <Plug>Yssurround
nmap S <Plug>Ysurround$

" }}}
"=============================================================================
" vim-jade : {{{

" 設定なし

" }}}
"=============================================================================
" unite-outline : {{{

" 設定なし

" }}}
"=============================================================================
" vim-alignta : {{{

" テキスト整形
xnoremap <silent>[Unite]a :<C-u>Unite alignta:arguments<CR>
let g:unite_source_alignta_preset_arguments = [
\     ["Align at '='", '=>\='],
\     ["Align at ':'", '01 :'],
\     ["Align at '|'", '|'   ],
\     ["Align at '/'", '/\//' ],
\     ["Align at ','", ','   ],
\ ]

" オプション設定
nnoremap <silent>[Unite]a :<C-u>Unite alignta:options<CR>
let s:comment_leadings = '^\s*\("\|#\|/\*\|//\|<!--\)'
let g:unite_source_alignta_preset_options = [
\     ["Justify Left",      '<<' ],
\     ["Justify Center",    '||' ],
\     ["Justify Right",     '>>' ],
\     ["Justify None",      '==' ],
\     ["Shift Left",        '<-' ],
\     ["Shift Right",       '->' ],
\     ["Shift Left  [Tab]", '<--'],
\     ["Shift Right [Tab]", '-->'],
\     ["Margin 0:0",        '0'  ],
\     ["Margin 0:1",        '01' ],
\     ["Margin 1:0",        '10' ],
\     ["Margin 1:1",        '1'  ],
\     'v/' . s:comment_leadings,
\     'g/' . s:comment_leadings,
\ ]
unlet s:comment_leadings

" }}}
"=============================================================================
" vim-operator-replace : {{{

" xpを置換用キーに設定
map xp "*<Plug>(operator-replace)
map xP xp$

" }}}
"=============================================================================
" vim-operator-user : {{{

" 検索オペレータ
map x/ <Plug>(operator-search)
call operator#user#define('search', 'OperatorSearch')
function! OperatorSearch(motion_wise)
    if a:motion_wise == 'char'
        silent normal! `[v`]"zy
        call search(@z)
        let @/ = @z
        set hlsearch
    endif
endfunction

" }}}
"=============================================================================
" vim-smartinput : {{{

" 設定なし

" }}}
"=============================================================================
" submode.vim : {{{

" タイムアウトあり
let g:submode_timeout = 1

" 入力待ち時間
let g:submode_timeoutlen = 800

" ウィンドウサイズ制御
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>5+')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>5-')
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>5>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w>5<')
call submode#map('winsize', 'n', '', '+', '<C-w>5+')
call submode#map('winsize', 'n', '', '-', '<C-w>5-')
call submode#map('winsize', 'n', '', '<', '<C-w>5<')
call submode#map('winsize', 'n', '', '>', '<C-w>5>')

" }}}
"=============================================================================
" vim-textobj-indent : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-entire : {{{

" 全行コピー
nmap yie yie`'
nmap yae yae`'

" }}}
"=============================================================================
" vim-textobj-lastpat : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-line : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-syntax : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-user : {{{

" キャメルケース、スネークケース
call textobj#user#plugin('camelcase', {
\     '-': {
\         '*pattern*': '[A-Za-z][a-z0-9]\+\|[A-Z]\+',
\         'select': ['ac', 'ic'],
\     },
\ })

" }}}
"=============================================================================
" calender.vim : {{{

" キーマップ
nnoremap <silent><F7> :<C-u>CalendarH<CR>
autocmd MyAutoCmd FileType calendar nmap <buffer><F7> q<CR>

" ステータスラインに現在日時を表示
let g:calendar_datetime='statusline'

" }}}
"=============================================================================
" mahjong-vim : {{{

" 設定なし

" }}}
"=============================================================================
" webapi-vim : {{{

" Google電卓
command! -bang -nargs=+ GCalc call GCalc(<q-args>, <bang>0)
function! GCalc(expr, banged)
    let res = http#get('http://www.google.co.jp/complete/search?output=toolbar&q='.http#escape(a:expr)).content
    if match(res, 'calculator_suggestion') == -1
        echohl ErrorMsg | echo 'Bad response' |  echohl None
        return
    endif
    let result = xml#parse(res).find('calculator_suggestion').attr['data']
    if !a:banged
        let @* = result
    endif
    echo result
endfunction

" }}}
"=============================================================================
" zencoding-vim : {{{

" キーマップ
let g:user_zen_leader_key = '<C-z>'

let g:user_zen_settings = {
\     'indentation' : '    '
\ }

" }}}
"=============================================================================
" vim-auto-colorscheme : {{{

" colorscheme設定
let g:auto_colorscheme_default = 'nevfn'
let g:auto_colorscheme_config = {
\     '^\.vimperatorrc' : 'murphy',
\ }

" }}}
"=============================================================================
" vim-textobj-space : {{{

" 設定なし

" }}}
"=============================================================================
" unite.vim : {{{

" 基本マップ
nnoremap [Unite] <Nop>
xnoremap [Unite] <Nop>
nmap <SPACE> [Unite]
xmap <SPACE> [Unite]

" 汎用
nnoremap [Unite]u :<C-u>Unite buffer_tab file_mru file file/new -buffer-name=files -no-split<CR>

" バッファ
nnoremap [Unite]b :<C-u>Unite buffer_tab -no-split<CR>

" grep
nnoremap [Unite]g :<C-u>Unite grep -no-quit<CR>
let g:unite_source_grep_default_opts = '-iRHn'

" ヘルプ
nnoremap [Unite]h :<C-u>Unite help -no-split<CR>
nnoremap [Unite]H :<C-u>UniteWithCursorWord help -no-split<CR>

" アウトライン
nnoremap [Unite]o :<C-u>Unite outline -no-split<CR>

" ヒストリ
nnoremap [Unite]: :<C-u>Unite history/command -no-split<CR>

" 検索履歴
nnoremap [Unite]/ :<C-u>Unite history/search -no-split<CR>

" phpマニュアル
nnoremap [Unite]p :<C-u>Unite ref/phpmanual -no-split<CR>

" バッファ内検索
nnoremap [Unite]l :<C-u>Unite line -no-quit<CR>

" ジャンクファイル
nnoremap [Unite]j :<C-u>Unite junk -no-split<CR>
let g:unite_source_alias_aliases = {'junk': {'source': 'file_rec', 'args': $HOME . '/.vim_junk/', }, }

" unite source
nnoremap [Unite]<SPACE> :<C-u>Unite source -no-split<CR>

" uniteファイルタイプ設定
autocmd MyAutoCmd FileType unite call <SID>UniteMySetting()
function! s:UniteMySetting()
    " 入力欄にフォーカス
    imap <buffer><expr>i unite#smart_map("i", "\<Plug>(unite_insert_leave)\<Plug>(unite_insert_enter)")

    " uniteを終了
    imap <buffer><ESC> <Plug>(unite_exit)
    nmap <buffer><ESC> <Plug>(unite_exit)

    " 編集
    inoremap <silent><buffer><expr><C-e> unite#do_action('edit')

    " ノーマルモードでの上下移動
    nmap <buffer><C-n> <Plug>(unite_loop_cursor_down)
    nmap <buffer><C-p> <Plug>(unite_loop_cursor_up)
endfunction

" 入力モードで開始
let g:unite_enable_start_insert = 1

" ¥を/に変換
if s:iswin && &shellslash == 0
    call unite#set_substitute_pattern('files', '\', '/')
endif

" カレントディレクトリ以下を探す
call unite#set_substitute_pattern('files', '^@/', '\=getcwd()', 1)

" 親ディレクトリを探す
call unite#set_substitute_pattern('files', ';', '../')

" file_mruの保存数
let g:unite_source_file_mru_limit = 1000

" file_mruの無視パターン
let g:unite_source_file_mru_ignore_pattern = ''
let g:unite_source_file_mru_ignore_pattern .= '\~$'
let g:unite_source_file_mru_ignore_pattern .= '\|\.\%(o\|exe\|dll\|bak\|sw[po]\)$'
let g:unite_source_file_mru_ignore_pattern .= '\|\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)'
let g:unite_source_file_mru_ignore_pattern .= '\|^\%(\\\\\|/mnt/\|/media/\|/Volumes/\)'
let g:unite_source_file_mru_ignore_pattern .= '\|AppData/Local/Temp'

" 検索キーワードをハイライトしない
let g:unite_source_line_enable_highlight = 0

" }}}
"=============================================================================
" neocomplcache : {{{

" neocomplcache有効
let g:neocomplcache_enable_at_startup = 1

" 大文字小文字を区別しない
let g:neocomplcache_enable_ignore_case = 1

" 大文字が含まれている場合は区別して補完
let g:neocomplcache_enable_smart_case = 1

" キャメルケース補完
let g:neocomplcache_enable_camel_case_completion = 1

" スネークケース補完
let g:neocomplcache_enable_underbar_completion = 1

" 日本語は収集しない
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" <TAB>で補完
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" 選択中の候補を確定
imap <expr><C-y> neocomplcache#close_popup()

" <CR>は候補を確定しながら改行
inoremap <expr><CR> neocomplcache#smart_close_popup() . <SID>ExCr()

" 補完をキャンセル
imap <expr><C-e> neocomplcache#cancel_popup()

" }}}
"=============================================================================
" neocomplcache-snippets-complete : {{{

" スニペット補完
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)

" }}}
"=============================================================================
" vimfiler : {{{

" デフォルトのファイラに設定
let vimfilerAsDefaultExplorer = 1

" vimfilerを開く
nnoremap E :<C-u>VimFiler<CR>

" vimfilerファイルタイプ設定
autocmd MyAutoCmd FileType vimfiler call <SID>VimfilerMySetting()
function! s:VimfilerMySetting()
    " ドットファイルを表示
    normal .

    " リネーム
    nmap <buffer><silent> R <Plug>(vimfiler_rename_file)

    " ディレクトリをリロード
    nmap <buffer><silent> r <Plug>(vimfiler_redraw_screen)

    " トグル選択
    nmap <buffer><silent> <SPACE> <Plug>(vimfiler_toggle_mark_current_line)
endfunction

" }}}
"=============================================================================
" vimproc : {{{

" 設定なし

" }}}
"=============================================================================
" vimshell : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-between : {{{

" 設定なし

" }}}
"=============================================================================
" vim-quickrun : {{{

" 実行コマンド設定
let g:quickrun_config = {}
let g:quickrun_config.javascript = {'command': $HOME . '/.nave/installed/0.6.11/bin/node'}

" }}}
"=============================================================================
" vim-ref : {{{

" phpマニュアルパス
let g:ref_phpmanual_path = '/Applications/XAMPP/xamppfiles/lib/php/php-chunked-xhtml/'

" html表示はw3m
let g:ref_phpmanual_cmd = 'w3m -dump %s'

" }}}
"=============================================================================
" unite-history : {{{

" 設定なし

" }}}
"=============================================================================
" vim-repeat : {{{

" 設定なし

" }}}
"=============================================================================
" vim-matchit : {{{

" 設定なし

" }}}
"=============================================================================
" unite-help : {{{

" 設定なし

" }}}
"=============================================================================
" openbrowser.vim : {{{

" URLなら開き、URLでない場合は検索を実行
nmap x@ <Plug>(openbrowser-smart-search)
xmap x@ <Plug>(openbrowser-smart-search)

" }}}
"=============================================================================
" operator-camelize.vim : {{{

" カーソル位置の単語をキャメルケース化/解除のトグル
map _ <Plug>(operator-camelize-toggle)iwbvu

" }}}
"=============================================================================
" TwitVim : {{{

" 取得数
let twitvim_count = 100

" }}}
"=============================================================================
" vcscommand.vim : {{{

" 設定なし

" }}}
"=============================================================================

" }}}
"=============================================================================
