#=======================================================
# PATH
#=======================================================
# PATH for rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

export MANPATH=/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH
export MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH
export NODE_PATH=/usr/local/share/npm/lib/node_modules:$NODE_PATH
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/Cellar/git/2.14.2/bin:$PATH"

# pyenvさんに~/.pyenvではなく、/usr/loca/var/pyenvを使うようにお願いする
export PYENV_ROOT=/usr/local/var/pyenv

# pyenvさんに自動補完機能を提供してもらう
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

#=======================================================
# alias
#=======================================================

# git
alias gs='git status'
alias gc='git commit -m'
alias ga='git add'
alias gd='git diff'
alias gl='git log'
alias gb='git branch -a'
alias gch='git checkout'

# vim, zsh
alias v='vim'
alias vi='vim'
alias zshrc='vim ~/.zshrc'

# python
alias jupy='jupyter notebook'

# ruby
alias be='bundle exec'

#=======================================================
# zplug
#=======================================================

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "zplug/zplug"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "unixorn/rake-completion.zshplugin"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "djui/alias-tips"
zplug "stedolan/jq", \
    from:gh-r, \
    as:command, \
    rename-to:jq
zplug "sorin-ionescu/prezto"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose


#=======================================================
# zsh config
#=======================================================
autoload colors && colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz compinit && compinit -C

setopt no_flow_control

# タイポしているコマンドを指摘
setopt correct

#cd
setopt auto_cd

setopt auto_pushd

setopt prompt_subst

# historyの共有
setopt share_history

# 重複を記録しない
setopt hist_ignore_dups

# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups

# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space

# 余分な空白は詰めて記録
setopt hist_reduce_blanks

# 古いコマンドと同じものは無視
setopt hist_save_no_dups

# historyコマンドは履歴に登録しない
setopt hist_no_store

# 補完時にヒストリを自動的に展開
setopt hist_expand

# 履歴をインクリメンタルに追加
setopt inc_append_history

# 開始と終了を記録
setopt EXTENDED_HISTORY

# コマンドラインでもコメントアウトができるように
setopt interactive_comments

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history

# メモリに保存される履歴の件数
export HISTSIZE=1000000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=1000000

#color
export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
export LESS='-g -i -M -R -S -W -z-4 -x4'
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'

zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'

#大文字小文字を意識しない補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#=======================================================

#----------------------------------
# for vcs_info
#----------------------------------
local git==git

function _precmd_vcs_info() {
  LANG=en_US.UTF-8 vcs_info
}
add-zsh-hook precmd _precmd_vcs_info
zstyle ':vcs_info:*' formats "%b" "%s"
zstyle ':vcs_info:*' actionformats "%b|%a" "%s"
function vcs_info_for_git() {
  VCS_GIT_PROMPT="${vcs_info_msg_0_}"
  VCS_GIT_PROMPT_CLEAN="%{${fg[cyan]}%}"
  #VCS_GIT_PROMPT_CLEAN="%{${fg[cyan]}%}"
  VCS_GIT_PROMPT_DIRTY="%{${fg[cyan]}%}"
  #VCS_GIT_PROMPT_DIRTY="%{${fg[yellow]}%}"

  VCS_GIT_PROMPT_ADDED="%{${fg[blue]}%}A%{${reset_color}%}"
  VCS_GIT_PROMPT_MODIFIED="%{${fg[red]}%}!%{${reset_color}%}"
  VCS_GIT_PROMPT_DELETED="%{${fg[red]}%}D%{${reset_color}%}"
  VCS_GIT_PROMPT_RENAMED="%{${fg[yellow]}%}R%{${reset_color}%}"
  VCS_GIT_PROMPT_UNMERGED="%{${fg[red]}%}U%{${reset_color}%}"
  VCS_GIT_PROMPT_UNTRACKED="%{${fg[red]}%}?%{${reset_color}%}"

  INDEX=$($git status --porcelain 2> /dev/null)
  LINE="$(time_since_commit)|"
  if [[ -z "$INDEX" ]];then
    LINE="$LINE${VCS_GIT_PROMPT_CLEAN}${VCS_GIT_PROMPT}%{${reset_color}%}"
  else
    if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_UNMERGED"
    fi
    if $(echo "$INDEX" | grep '^R ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_RENAMED"
    fi
    if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_DELETED"
    fi
    if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_MODIFIED"
    fi
    if $(echo "$INDEX" | grep '^A ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_ADDED"
    elif $(echo "$INDEX" | grep '^M ' &> /dev/null); then
      STATUS="$VCS_GIT_PROMPT_ADDED"
    fi
    LINE="$LINE${VCS_GIT_PROMPT_DIRTY}${VCS_GIT_PROMPT}%{${reset_color}%}$STATUS"
  fi
  echo "${LINE}"
}

function minutes_since_last_commit {
    now=`date +%s`
    last_commit=`$git log --pretty=format:'%at' -1 2>/dev/null`
    if $lastcommit ; then
      seconds_since_last_commit=$((now-last_commit))
      minutes_since_last_commit=$((seconds_since_last_commit/60))
      echo $minutes_since_last_commit
    else
      echo "-1"
    fi
}

function time_since_commit() {
  local -A pc

  if [[ -n "${vcs_info_msg_0_}" ]]; then
      local MINUTES_SINCE_LAST_COMMIT=`minutes_since_last_commit`
      if [ "$MINUTES_SINCE_LAST_COMMIT" -eq -1 ]; then
        COLOR="%{${fg[red]}%}"
        local SINCE_LAST_COMMIT="${COLOR}uncommitted%{${reset_color}%}"
      else
        if [ "$MINUTES_SINCE_LAST_COMMIT" -gt 30 ]; then
          COLOR="%{${fg[red]}%}"
        elif [ "$MINUTES_SINCE_LAST_COMMIT" -gt 10 ]; then
          COLOR="%{${fg[red]}%}"
        else
          COLOR="%{${fg[red]}%}"
        fi
        local SINCE_LAST_COMMIT="${COLOR}$(minutes_since_last_commit)m%{${reset_color}%}"
      fi
      echo $SINCE_LAST_COMMIT
  fi
}

function vcs_info_with_color() {

  if [[ `pwd` =~ ".*\/mnts\/.*" ]]; then
    return ""
  fi

  VCS_PROMPT_PREFIX="("
  VCS_PROMPT_SUFFIX=")"

  VCS_NOT_GIT_PROMPT="%{${fg[green]}%}${vcs_info_msg_0_}%{${reset_color}%}"

  if [[ -n "${vcs_info_msg_0_}" ]]; then
    if [[ "${vcs_info_msg_1_}" = "git" ]]; then
      STATUS=$(vcs_info_for_git)
    else
      STATUS=${VCS_NOT_GIT_PROMPT}
    fi
    echo "${VCS_PROMPT_PREFIX}${STATUS}${VCS_PROMPT_SUFFIX}"
  fi
}

function current_dir() {
  echo `pwd | rev | cut -d '/' -f 1 | rev`
}

PROMPT='$(current_dir)$(vcs_info_with_color) %{${fg[yellow]}%}$%{${reset_color}%} '

# ----------------------
# Git Function
# ----------------------
# Git log find by commit message
function glf() { $git log --all --grep="$1"; }

# iTermのタブに現在のディレクトリと一つ上のディレクトリを表示
function chpwd() { ls -a; echo -ne "\033]0;$(pwd | rev | awk -F \/ '{print "/"$1"/"$2}'| rev)\007"}

# pecoに関する設定(インクリメンタルサーチ用)
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

