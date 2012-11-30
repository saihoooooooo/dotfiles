export PATH=/opt/local/bin:/opt/local/sbin/:/Applications/XAMPP/xamppfiles/bin/:~/.npm/bin:$PATH
export MANPATH=/opt/local/man:~/.npm/man:$MANPATH
export NODE_PATH=~/.npm/libraries:$NODE_PATH

# 文字コードの設定
export LANG=ja_JP.UTF-8

# デフォルトキーバインド
bindkey -d
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# エイリアス
alias ls='ls -a'
alias rm='rm -i'
alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"
alias ctags="`brew --prefix`/bin/ctags"
alias nave=$HOME/.nave/nave/nave.sh

# 補完
autoload -U compinit
compinit 
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'

# プロンプト 
PROMPT='%m %# '
RPROMPT="%~ [%T]"

# ヒストリ
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

# ヒストリの共有
setopt share_history

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups

# ヒストリにhistoryコマンドを記録しない
setopt hist_no_store

# 余分なスペースを削除してヒストリに記録する
setopt hist_reduce_blanks

# 履歴ファイルに時刻を記録
setopt extended_history

# sudo でも補完の対象
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加
setopt append_history

# 補完候補が複数ある時に、一覧表示
setopt auto_list

# 保管結果を詰めて表示
setopt list_packed

# 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完
setopt auto_menu

# カッコの対応などを自動的に補完
setopt auto_param_keys

# ビープ音を鳴らさないようにする
setopt no_beep

# 8 ビット目を通すようになり、日本語のファイル名を表示可能
setopt print_eight_bit

# ディレクトリを水色にする｡
export LS_COLORS='di=01;36'

# ファイルリスト補完でもlsと同様に色をつける｡
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# cd をしたときにlsを実行する
function chpwd() { ls }

# cdの履歴を保存
setopt auto_pushd

# git補完
autoload bashcompinit
bashcompinit
source ~/.git-completion.sh

# node
nave use 0.8.0

# Ctrl-D でログアウトさせない。ただし、10回連続で Ctrl-D すると ログアウトする
setopt IGNOREEOF