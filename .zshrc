# users generic .zshrc file for zsh(1)
#
# usage : "ln -s .dotfiles/.zshenv ./ "して.dotfilesの中の.zshrcを読み込むようにしてね！
#


## Environment variable configuration
#
# LANG
#
export LANG=ja_JP.UTF-8

export TERM=xterm-256color

## Default shell configuration
#
# set prompt
#
autoload colors
colors
#case ${UID} in
#0)
#    PROMPT="%B%{${fg[green]}%}%/#%{${reset_color}%}%b "
#    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
#    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
#    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
#        PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
#    ;;
#*)
#    PROMPT="%{${fg[blue]}%}%(5~,%-2~/.../%2~,%~) %(!.#.$)%{${reset_color}%} "
#    PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "
#    SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
#    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
#        PROMPT="%B%{${fg[green]}%}%n@%m ${PROMPT}%b"
#    ;;
#esac

PROMPT="%B%{${fg[green]}%}%n@%m %{${fg[blue]}%}%(9~,%-3~/.../%3~,%~) %(!.#.$)%{${reset_color}%}%b "

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


## terminal configuration
#
unset LSCOLORS
case "${TERM}" in
xterm)
    export TERM=xterm-color
    ;;
kterm)
    export TERM=kterm-color
    # set BackSpace control character
    stty erase
    ;;
cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors \
        'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac

# set terminal title including current directory
#
case "${TERM}" in
kterm*|xterm*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors \
        'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
esac

JAVA_HOME=/usr/local/java/jdk1.7.0_03
export JAVA_HOME

# lv
alias lv='lv -c'

# emacs
#alias emacs='emacs -nw'

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
alias -g W='| wc'

stty stop undef
stty start undef

# for screen 実行したコマンドで、ScreenのWindow名を変更する
preexec(){
    echo -ne "\ek${HOST%%.*}:${1%% *}\e\\"
}

if [ -d ${HOME}/.rbenv ]; then
  export PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
  if [ -d ${HOME}/.rbenv/completions/rbenv.zsh ]; then
      . ~/.rbenv/completions/rbenv.zsh
  fi
fi

### Added by the Heroku Toolbelt
export PATH="~/bin:/usr/local/heroku/bin:$PATH"

## 各環境毎の設定を読み込む
[ -f $ZDOTDIR/.zshrc_`uname` ] && . $ZDOTDIR/.zshrc_`uname`

## ローカルの設定を読み込む
[ -f $ZDOTDIR/.zshrc_local ] && . $ZDOTDIR/.zshrc_local

# lv使うとgit diffのカラーコードが表示できない問題の対応
export GIT_PAGER=less
if [[ -x `whence -p lv` ]]; then
  export GIT_PAGER="lv -c"
fi

