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

" }}}
"=============================================================================
" 文字コード設定 : {{{

" 内部文字コード
set encoding=utf-8

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
command! -bang -bar -complete=file -nargs=? Utf16 edit<bang> ++enc=ucs-2le <args>
command! -bang -bar -complete=file -nargs=? Utf16be edit<bang> ++enc=ucs-2 <args>

" 各種改行コードで開き直す
command! -bang -bar -complete=file -nargs=? Unix edit<bang> ++fileformat=unix <args>
command! -bang -bar -complete=file -nargs=? Dos edit<bang> ++fileformat=dos <args>
command! -bang -bar -complete=file -nargs=? Mac edit<bang> ++fileformat=mac <args>

" 文字コード/改行コード指定（Scratch用）
nnoremap xft :set ft=
nnoremap xff :set ff=

" }}}
"=============================================================================
" 表示設定 : {{{

" 表示メッセージロケール
language message C

" シンタックスON
if !exists("syntax_on")
    syntax enable
endif

" シンタックス有効桁数
set synmaxcol=1000

" シンタックスON/OFF切り替え
nnoremap <expr><F3> exists("syntax_on") ? ":\<C-u>syntax off\<CR>" : ":\<C-u>syntax enable\<CR>"

" 全画面表示
if s:iswin
    autocmd MyAutoCmd GUIEnter * FullScreen
else
    autocmd MyAutoCmd GUIEnter * set columns=1000 lines=1000
endif

" GUIオプション
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
if !exists("colors_name")
    autocmd MyAutoCmd GUIEnter * colorscheme BlackSea
endif

" 半透明
if has('gui_running')
    if s:iswin
        autocmd MyAutoCmd GUIEnter * set transparency=220
    else
        set transparency=10
    endif
endif

" ステータスラインを常に表示
set laststatus=2

" ステータスライン表示内容
let &statusline = ''
let &statusline .= '%{expand("%:p:t")}'
let &statusline .= '%h%w%m%r'
let &statusline .= ' (%<%{expand("%:p:h")}) '
let &statusline .= '%='
let &statusline .= '[HEX:%B][R:%l][C:%c]'
let &statusline .= '%y'
let &statusline .= '[%{&fileencoding}][%{&fileformat}]'

" コマンドライン行数
autocmd MyAutoCmd GUIEnter * set cmdheight=1

" 入力中コマンドを表示
set showcmd

" 現在のモードを表示
set showmode

" 相対行番号を表示
set relativenumber

" 行を折り返さない
set nowrap

" 現在行のハイライト
set cursorline
autocmd MyAutoCmd WinLeave * set nocursorline
autocmd MyAutoCmd WinEnter,BufRead * set cursorline

" 括弧の対応表示を行う
set showmatch

" カーソルの上または下に表示する最低行数
set scrolloff=5

" <TAB>、行末スペース、スクロール中の行頭文字の可視化
set list
set listchars=tab:>\ ,trail:-,nbsp:%,precedes:<

" 全角スペースを視覚化
autocmd MyAutoCmd VimEnter,WinEnter,WinLeave * match IdeographicSpace /　/
if (has('gui_running'))
    autocmd MyAutoCmd GUIEnter * highlight IdeographicSpace term=underline ctermbg=Gray guibg=Gray50
else
    highlight IdeographicSpace term=underline ctermbg=Gray guibg=Gray50
endif

" 全角文字表示幅
if exists('&ambiwidth')
    set ambiwidth=double
endif

" }}}
"=============================================================================
" インデント設定 : {{{

" <TAB>は空白を使用
set expandtab

" <Tab>が対応する空白量
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

" キーマップ確定
nnoremap <CR> <Nop>

" 全てのキーマップを表示
command! -nargs=* -complete=mapping AllMaps map <args> | map! <args> | lmap <args>

" IME状態を保存しない
if has('multi_byte_ime')
    set iminsert=0
    set imsearch=0
    inoremap <silent><ESC> <ESC>
endif

" xを封印
nnoremap x <Nop>

" 全角入力時のカーソルの色を変更
autocmd MyAutoCmd GUIEnter * highlight CursorIM guibg=Purple guifg=NONE

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
" 編集設定 : {{{

" バックスペース対象
set backspace=indent,eol,start

" Yの動作をDやCと同じにする
map Y y$

" ビジュアルモード時は最後にヤンクした内容をペースト
" vnoremap p "0p

" 行連結
noremap + J

" 空行を挿入
nnoremap <silent>O :call append(expand('.'), '')<CR>j

" ノーマルモードでの改行
nnoremap <S-CR> i<CR><ESC>

" コメントを継続しない
autocmd MyAutoCmd FileType * setlocal formatoptions-=o formatoptions-=r

" インサートモード中の履歴保存
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w> <C-g>u<C-w>

" 最後に編集した内容を選択
nnoremap gs `[v`]<LEFT>

" 強制全保存終了を無効化
nnoremap ZZ <Nop>

" ^Mを取り除く
command! -nargs=0 RemoveCr :silent! normal! mg:%s/<C-v><CR>//g<CR>:nohlsearch<CR>`g

" 行末のスペースを取り除く
command! -nargs=0 RemoveEolSpace :silent! normal! mg:%s/ \+$//g<CR>:nohlsearch<CR>`g

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

" }}}
"=============================================================================
" 移動設定 : {{{

" 10行移動
noremap J 10j
noremap K 10k

" wの動作をeに変更
noremap w e

" カーソルを行頭、行末で止まらないようにする
set whichwrap=h,l,[,],<,>

" ビジュアルモード時の$は改行まで移動しない
vnoremap $ $<LEFT>

" 対応移動ペア
set matchpairs=(:),{:},[:],<:>

" 対応移動をeにマップ
map e %

" ワンキー関数移動
nmap } ]]
nmap { [[

" }}}
"=============================================================================
" 検索設定 : {{{

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

" 循環検索のトグル
nnoremap <expr>x/ &wrapscan ? ":\<C-u>set nowrapscan\<CR>" : ":\<C-u>set wrapscan\<CR>"

" <ESC>でハイライト消去
nnoremap <silent><ESC> :nohlsearch<CR>

" q/を無効化
nnoremap q/ <Nop>

" }}}
"=============================================================================
" コマンド設定 : {{{

" コマンド補完候補を表示
set wildmenu

" 補完モード
set wildmode=full

" コマンド実行中は再描画しない
" set lazyredraw

" コマンドの出力を別ウィンドウで開く
command! -nargs=+ -complete=command Capture call <SID>CmdCapture(<q-args>)
function! s:CmdCapture(cmd)
    redir => result
    silent execute a:cmd
    redir END
    new
    file `='Capture: ' . a:cmd`
    setlocal bufhidden=unload nobuflisted buftype=nofile noswapfile
    call setline(1, split(substitute(result, '^\n\+', '', ''), '\n'))
endfunction

" q:を無効化
nnoremap q: <Nop>

" }}}
"=============================================================================
" ファイル設定 : {{{

" ファイルパス区切り文字
if s:iswin
    " set shellslash
endif

" 拡張子毎のfiletype指定
autocmd MyAutoCmd BufRead,BufNewFile *.ctp set filetype=php

" 編集中ファイルのリネーム
command! -nargs=1 -complete=file Rename file <args> | w | call delete(expand('#'))

" 使い捨てファイル
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
nnoremap <silent><S-BS> :bwipeout<CR>

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

" 自動調整を行わない
set equalalways

" サイズ調整は幅と高さ
set eadirection=both

" 他のウィンドウを閉じる
nnoremap <C-w>O <C-w>o

" ウィンドウを複製
nnoremap <C-w>w :<C-u>vert new %<CR>

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
set guitablabel=%t%m

" 基本マップ
nnoremap [Tab] <Nop>
nmap <C-t> [Tab]

" タプを作成
nnoremap [Tab]n :<C-u>99tabnew<CR>
nnoremap [Tab]N :tabnew<CR>

" 次/前のタプ
nnoremap [Tab]l gt
nnoremap [Tab]h gT

" タブを移動
nnoremap [Tab]H :<C-u>call <SID>MoveTabPosition('left')<CR>
nnoremap [Tab]L :<C-u>call <SID>MoveTabPosition('right')<CR>
nnoremap [Tab]K :<C-u>call <SID>MoveTabPosition('top')<CR>
nnoremap [Tab]J :<C-u>call <SID>MoveTabPosition('bottom')<CR>
function! s:MoveTabPosition(direction)
    if a:direction == 'left'
        execute 'tabmove ' . (tabpagenr() - 2)
    elseif a:direction == 'right'
        execute 'tabmove ' . (tabpagenr())
    elseif a:direction == 'top'
        execute 'tabmove 0'
    elseif a:direction == 'bottom'
        execute 'tabmove 99'
    endif
endfunction

" タプを閉じる
nnoremap [Tab]c :<C-u>tabclose<CR>

" 現在以外のタプを閉じる
nnoremap [Tab]o :<C-u>tabonly<CR>

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
set clipboard+=unnamed

" }}}
"=============================================================================
" マーク設定 : {{{

" 内容確認
nnoremap M :<C-u>marks<CR>

" gg実行時に現在行をマーク
nnoremap gg mggg

" G実行時に現在行をマーク
nnoremap G mgG

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

" プレビューウィンドウで開く
nnoremap [Tag]o <C-w>}<C-w>P

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

"=============================================================================
" neobundle.vim # プラグイン管理 : {{{

" 初期化
if has('vim_starting')
    filetype off
    set runtimepath+=$DOTVIM/bundle/neobundle.vim
    call neobundle#rc(expand($DOTVIM . '/bundle'))
    filetype plugin on
    filetype indent on
endif

" 各種plugin
NeoBundle 'git://github.com/anyakichi/vim-surround.git'
NeoBundle 'git://github.com/basyura/TweetVim.git'
NeoBundle 'git://github.com/h1mesuke/unite-outline.git'
NeoBundle 'git://github.com/h1mesuke/vim-alignta.git'
NeoBundle 'git://github.com/kana/vim-operator-replace.git'
NeoBundle 'git://github.com/kana/vim-operator-user.git'
NeoBundle 'git://github.com/kana/vim-submode.git'
NeoBundle 'git://github.com/kana/vim-textobj-indent.git'
NeoBundle 'git://github.com/kana/vim-textobj-entire.git'
NeoBundle 'git://github.com/kana/vim-textobj-lastpat.git'
NeoBundle 'git://github.com/kana/vim-textobj-syntax.git'
NeoBundle 'git://github.com/kana/vim-textobj-user.git'
NeoBundle 'git://github.com/mattn/calendar-vim.git'
NeoBundle 'git://github.com/mattn/mahjong-vim.git'
NeoBundle 'git://github.com/mattn/webapi-vim.git'
NeoBundle 'git://github.com/Shougo/git-vim.git'
NeoBundle 'git://github.com/Shougo/unite.vim.git'
NeoBundle 'git://github.com/Shougo/neobundle.vim.git'
NeoBundle 'git://github.com/Shougo/neocomplcache.git'
NeoBundle 'git://github.com/Shougo/vimfiler.git'
NeoBundle 'git://github.com/Shougo/vimproc.git'
NeoBundle 'git://github.com/Shougo/vimshell.git'
NeoBundle 'git://github.com/taku-o/vim-changed.git'
NeoBundle 'git://github.com/thinca/vim-textobj-between.git'
NeoBundle 'git://github.com/thinca/vim-quickrun.git'
NeoBundle 'git://github.com/thinca/vim-ref.git'
NeoBundle 'git://github.com/thinca/vim-unite-history.git'
NeoBundle 'git://github.com/tpope/vim-repeat.git'
NeoBundle 'git://github.com/tsaleh/vim-matchit.git'
NeoBundle 'git://github.com/tsukkee/unite-help.git'
NeoBundle 'git://github.com/tyru/operator-camelize.vim.git'
NeoBundle 'git://github.com/vim-jp/vimdoc-ja.git'
NeoBundle 'git://github.com/vim-scripts/TwitVim.git'
NeoBundle 'git://github.com/vim-scripts/vcscommand.vim.git'
NeoBundle 'git://github.com/vim-scripts/ZoomWin.git'

" }}}
"=============================================================================
" vim-surround # テキストオブジェクトでの囲い操作 : {{{

" キーマップ
nmap s <Plug>Ysurround
nmap ss <Plug>Yssurround
nmap S <Plug>Ysurround$

" }}}
"=============================================================================
" vim-alignta # テキスト整形 : {{{

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
" vim-operator-replace # 置換オペレータ : {{{

" zpを置換用キーに設定
map zp "*<Plug>(operator-replace)
map zP zp$

" }}}
"=============================================================================
" vim-operator-user # ユーザ定義オペレータ : {{{

" 設定なし

" }}}
"=============================================================================
" submode.vim # ユーザ定義モード : {{{

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
" vim-textobj-indent # インデントテキストオブジェクト : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-entire # 全行テキストオブジェクト : {{{

" 全行コピー
nmap yie yie`'
nmap yae yae`'

" }}}
"=============================================================================
" vim-textobj-lastpat # 検索結果テキストオブジェクト : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-syntax # シンタックステキストオブジェクト : {{{

" 設定なし

" }}}
"=============================================================================
" vim-textobj-user # ユーザ定義テキストオブジェクト : {{{

" キャメルケース、スネークケース
call textobj#user#plugin('camelcase', {
\     '-': {
\         '*pattern*': '[A-Za-z][a-z0-9]\+\|[A-Z]\+',
\         'select': ['ac', 'ic'],
\     },
\ })

" スペース
call textobj#user#plugin('space', {
\     '-': {
\         '*pattern*': '\s\+',
\         'select': ['as', 'is'],
\     },
\ })

" }}}
"=============================================================================
" calender.vim # カレンダー表示 : {{{

" キーマップ
nnoremap <silent><F7> :<C-u>CalendarH<CR>
autocmd MyAutoCmd FileType calendar nmap <buffer><F7> q<CR>

" ステータスラインに現在日時を表示
let g:calendar_datetime='statusline'

" }}}
"=============================================================================
" mahjong-vim # 麻雀早上がりゲーム : {{{

" 設定なし

" }}}
"=============================================================================
" webapi-vim # WEBAPI取得 : {{{

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
" git-vim # vim上でgitコマンドを実行 : {{{

" 設定なし

" }}}
"=============================================================================
" unite.vim # すべてのsourceを統合する : {{{

" 基本マップ
nnoremap [Unite] <Nop>
xnoremap [Unite] <Nop>
nmap <SPACE> [Unite]
xmap <SPACE> [Unite]

" 汎用
nnoremap [Unite]u :<C-u>Unite buffer_tab file_mru file -buffer-name=files -no-split<CR>

" バッファ
nnoremap [Unite]b :<C-u>Unite buffer_tab -no-split<CR>

" grep
nnoremap [Unite]g :<C-u>Unite grep -no-quit<CR>
let g:unite_source_grep_default_opts = '-iRHn'

" ヘルプ
nnoremap [Unite]h :<C-u>Unite help -no-split<CR>

" アウトライン
nnoremap [Unite]o :<C-u>Unite outline -no-split<CR>

" ヒストリ
nnoremap [Unite]: :<C-u>Unite history/command -no-split<CR>

" 検索履歴
nnoremap [Unite]/ :<C-u>Unite history/search -no-split<CR>

" PHPマニュアル
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
    imap <buffer><expr>i unite#smart_map("i", "\<ESC>\<Plug>(unite_insert_enter)")

    " uniteを終了
    nmap <buffer><ESC> <Plug>(unite_exit)

    " 上に開く
    " imap <silent><buffer><expr><C-k> unite#do_action('above')

    " 下に開く
    " imap <silent><buffer><expr><C-j> unite#do_action('below')

    " 左に開く
    " imap <silent><buffer><expr><C-h> unite#do_action('left')

    " 右に開く
    " imap <silent><buffer><expr><C-l> unite#do_action('right')

    " タブで開く
    " imap <silent><buffer><expr><C-t> unite#do_action('tabopen')

    " エディット
    imap <silent><buffer><expr><C-e> unite#do_action('edit')

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
call unite#set_substitute_pattern('files', '^@', '\=getcwd()')

" file_mruの保存数
let g:unite_source_file_mru_limit = 1000

" 検索キーワードをハイライトしない
let g:unite_source_line_enable_highlight = 0

" }}}
"=============================================================================
" neocomplcache # 自動補完 : {{{

" neocomplcache有効
let g:neocomplcache_enable_at_startup = 1

" 大文字小文字を区別しない
let g:neocomplcache_enable_ignore_case = 1

" 大文字が含まれている場合は区別して補完
let g:neocomplcache_enable_smart_case = 1

" キャメルケース補完
let g:neocomplcache_enable_underbar_completion = 1

" アンダーバー区切り補完
let g:neocomplcache_enable_camel_case_completion = 1

" 日本語は収集しない
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" <TAB>で補完
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" スニペット補完
imap <C-k> <Plug>(neocomplcache_snippets_expand)

" 選択中の候補を確定
imap <expr><C-y> neocomplcache#close_popup()

" <CR>は候補を確定しながら改行
inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"

" 補完をキャンセル
imap <expr><C-e> neocomplcache#cancel_popup()

" unite.vimでの候補絞り込み
imap <C-l> <Plug>(neocomplcache_start_unite_complete)

" }}}
"=============================================================================
" vimfiler # 高機能ファイラ : {{{

" デフォルトのファイラに設定
let vimfilerAsDefaultExplorer = 1

" vimfilerを開く
nnoremap E :<C-u>VimFiler<CR>

" vimfilerファイルタイプ設定
autocmd MyAutoCmd FileType vimfiler call <SID>VimfilerMySetting()
function! s:VimfilerMySetting()
    " リネーム
    nmap <buffer><silent> R <Plug>(vimfiler_rename_file)

    " ディレクトリをリロード
    nmap <buffer><silent> r <Plug>(vimfiler_redraw_screen)

    " トグル選択
    nmap <buffer><silent> <SPACE> <Plug>(vimfiler_toggle_mark_current_line)
endfunction

" }}}
"=============================================================================
" vimproc # 非同期実行 : {{{

" 設定なし

" }}}
"=============================================================================
" vimshell # vim用shell : {{{

" 設定なし

" }}}
"=============================================================================
" vim-changed # 変更箇所の可視化 : {{{

" キーマップ
nnoremap <silent><F8> :<C-u>Changed<CR>

" }}}
"=============================================================================
" vim-textobj-between # 指定文字内テキストオブジェクト : {{{

" 設定なし

" }}}
"=============================================================================
" vim-quickrun # 編集中スクリプトを実行 : {{{

" 設定なし

" }}}
"=============================================================================
" vim-ref # リファレンス : {{{

" phpマニュアルパス
let g:ref_phpmanual_path = '/Applications/XAMPP/xamppfiles/lib/php/php-chunked-xhtml/'

" html表示はw3m
let g:ref_phpmanual_cmd = 'w3m -dump %s'

" }}}
"=============================================================================
" vim-repeat # surround.vimを.に対応 : {{{

" 設定なし

" }}}
"=============================================================================
" vim-matchit # %での対応移動を強化 : {{{

" 設定なし

" }}}
"=============================================================================
" operator-camelize.vim # キャメルケース変換オペレータ : {{{

" カーソル位置の単語をキャメルケース化/解除のトグル
map _ <Plug>(operator-camelize-toggle)iwbvu

" }}}
"=============================================================================
" TwitVim # Twitterクライアント : {{{

" 取得数
let twitvim_count = 100

" vimfilerファイルタイプ設定
autocmd FileType twitvim call <SID>TwitVimMySetting()
function! s:TwitVimMySetting()
    " 折り返し表示
    set wrap

    " リロード
    nnoremap <buffer>r :<C-u>FriendsTwitter<CR>
endfunction

" }}}
"=============================================================================
" vcscommand.vim # vim上でVCSコマンドを実行 : {{{

" 設定なし

" }}}
"=============================================================================
" ZoomWin # 複数ウィンドウ、単一ウィンドウの切り替え : {{{

" 設定なし

" }}}
"=============================================================================

" }}}
"=============================================================================
