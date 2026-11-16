# users generic .zshrc file for zsh(1)
#
# usage : "ln -s .dotfiles/.zshenv ./ "して.dotfilesの中の.zshrcを読み込むようにしてね！
#


## Environment variable configuration
#
# LANG
#
export LANG=ja_JP.UTF-8

# TERM はターミナル側に任せる（.zshrc で上書きしない）
#   iTerm2: Profiles > Terminal > Report terminal type = xterm-256color
#   tmux  : ~/.tmux.conf で set -g default-terminal "tmux-256color"

## Default shell configuration
#
# set prompt
#
PROMPT="%B%F{green}%n@%m %F{blue}%(9~,%-3~/.../%3~,%~) %(!.#.$)%f%b "

# show current git branch on the right prompt
#
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{green}(%b)%f'
zstyle ':vcs_info:git:*' actionformats '%F{yellow}(%b|%a)%f'
precmd_functions+=(vcs_info)
setopt prompt_subst
RPROMPT='${vcs_info_msg_0_}'

# auto change directory
#
setopt auto_cd

# auto directory pushd that you can get dirs list by cd -[tab]
#
setopt auto_pushd

# command correct edition before each completion attempt
#
setopt correct

# compacked complete list display
#
setopt list_packed

# no remove postfix slash of command line
#
setopt noautoremoveslash

# no beep sound when complete list displayed
#
setopt nolistbeep


## Keybind configuration
#
# emacs like keybind (e.x. Ctrl-a goes to head of a line and Ctrl-e goes
#   to end of it)
#
bindkey -e

# historical backward/forward search with linehead string binded to ^P/^N
#
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end


## Command history configuration
#
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data


## Completion configuration
#
fpath=(~/.zsh/functions/Completion ${fpath})
autoload -U compinit
compinit


## zsh editor
#
autoload zed


## Prediction configuration
#
#autoload predict-on
#predict-off


## Alias configuration
#
# expand aliases before completing
#
setopt complete_aliases     # aliased ls needs if file/dir completions work

alias where="command -v"
alias j="jobs -l"

case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -G -w"
    ;;
linux*)
    alias ls="ls --color"
    ;;
esac

alias la="ls -a"
alias lf="ls -F"
alias ll="ls -l --si"

alias du="du -h"
alias df="df -h"

alias su="su -l"

case "${OSTYPE}" in
darwin*)
    alias updateports="sudo port selfupdate; sudo port outdated"
    alias portupgrade="sudo port upgrade installed"
    ;;
freebsd*)
    case ${UID} in
    0)
        updateports()
        {
            if [ -f /usr/ports/.portsnap.INDEX ]
            then
                portsnap fetch update
            else
                portsnap fetch extract update
            fi
            (cd /usr/ports/; make index)

            portversion -v -l \<
        }
        alias appsupgrade='pkgdb -F && BATCH=YES NO_CHECKSUM=YES portupgrade -a'
        ;;
    esac
    ;;
esac


## color configuration
#
# LSCOLORS: BSD ls (macOS) 用 / LS_COLORS: GNU ls と補完候補用
#export LSCOLORS=exfxcxdxbxegedabagacad
#export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# 補完候補の色を LS_COLORS と連動させる
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

## terminal configuration
#
# set terminal title including current directory
#
case "${TERM}" in
kterm*|xterm*|screen*|tmux*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# lv
alias lv='lv -c'

# emacs
alias emacs='emacs -nw'

#screen
alias screen='screen -xR'

# PAGER
export PAGER='lv -c'

alias -g L='| lv -c'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g W='| wc'
alias -g S='| sed'
alias -g A='| awk'

stty stop undef
stty start undef

# tmux の中だけ、Window 名を「実行中はコマンド名、待っている間はディレクトリ名」にする
# tmux の自動命名 (automatic-rename) は名前の反映が遅れるため、zsh から直接送る
# （~/.tmux.conf の allow-rename on が必要）
if [[ -n "$TMUX" ]]; then
    autoload -Uz add-zsh-hook
    # 今のディレクトリ名 (ホームは ~)
    _tmux_window_dir() {
        if [[ "$PWD" == "$HOME" ]]; then
            print -rn -- '~'
        else
            print -rn -- "${PWD:t}"
        fi
    }
    _tmux_window_name_preexec() {
        # 実行するコマンドラインの最初の単語 (コマンド名)
        # (1 語だけのときに文字列扱いにならないよう、配列に分けてから取り出す)
        local -a words=(${(z)1})
        # 前に付いた環境変数の代入 (FOO=1 make の FOO=1) は飛ばす
        while (( ${#words} > 1 )) && [[ "${words[1]}" =~ '^[A-Za-z_][A-Za-z0-9_]*=' ]]; do
            shift words
        done
        local cmd="${words[1]}"
        # Claude Code はどのリポジトリで動いているかがわかるよう、ディレクトリ名も付ける
        [[ "$cmd" == claude ]] && cmd="claude:$(_tmux_window_dir)"
        printf '\ek%s\e\\' "$cmd"
    }
    _tmux_window_name_precmd() {
        printf '\ek%s\e\\' "$(_tmux_window_dir)"
    }
    add-zsh-hook preexec _tmux_window_name_preexec
    add-zsh-hook precmd _tmux_window_name_precmd
fi

if [ -d ${HOME}/.rbenv ]; then
  export PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
  if [ -f ${HOME}/.rbenv/completions/rbenv.zsh ]; then
      . ~/.rbenv/completions/rbenv.zsh
  fi
fi

### Added by the Heroku Toolbelt
export PATH="$HOME/bin:/usr/local/heroku/bin:$PATH"

## 各環境毎の設定を読み込む
[ -f $ZDOTDIR/.zshrc_`uname` ] && . $ZDOTDIR/.zshrc_`uname`

## ローカルの設定を読み込む
[ -f $ZDOTDIR/.zshrc_local ] && . $ZDOTDIR/.zshrc_local

# git diff の色を正しく表示するため less -R を使う
export GIT_PAGER='less -R'

# Android Studio
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

# Java ( brew install openjdk@21 )
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@21/include"

export PATH="$HOME/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/kitamura/.lmstudio/bin"
# End of LM Studio CLI section

# NOTE: これが最後に先頭へ追加されるため、java は openjdk@21 ではなく @17 が優先される
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
