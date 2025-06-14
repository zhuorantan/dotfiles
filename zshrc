# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# brew
BREWPREFIX="/opt/homebrew"
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/brew/Brewfile"
[[ ! -f "${BREWPREFIX}/bin/brew" ]] || eval "$(${BREWPREFIX}/bin/brew shellenv)"
export FPATH="${BREWPREFIX}/share/zsh/site-functions:${FPATH}"


# fzf
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
export FZF_DEFAULT_OPTS="--cycle --layout=reverse"


# editor
if [ -z "${NVIM}" ]; then
    export VISUAL="nvim"
else
    export VISUAL="nvim --server ${NVIM} --remote-tab"
fi
export MANPAGER="$VISUAL +Man! -"


# python
if [ -d "${BREWPREFIX}/opt/python/libexec/bin" ]; then
    export PATH="${BREWPREFIX}/opt/python/libexec/bin:${PATH}"
fi
# ruby
if [ -d "${BREWPREFIX}/lib/ruby/gems" ]; then
    export GEM_HOME="${BREWPREFIX}/lib/ruby/gems"
    export PATH="${GEM_HOME}/bin:${BREWPREFIX}/opt/ruby/bin:${PATH}"
fi
# node
if [ -d "${HOME}/.bun/bin" ]; then
    export PATH="${HOME}/.bun/bin:${PATH}"
fi
if [ -d "/usr/share/nvm" ]; then
    source /usr/share/nvm/init-nvm.sh
fi

typeset -U PATH # remove duplicated entries in $PATH


# ohmyzsh
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z colored-man-pages history docker fzf tmux)
source ${ZSH}/oh-my-zsh.sh

if [ -d "${BREWPREFIX}" ]; then
    source ${BREWPREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${BREWPREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${BREWPREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme
else
    if [ -d "/usr/share/zsh/plugins" ]; then
        source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    else
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi

# powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# proxy
if [ -n "$(nmap -p 7890 localhost | grep open)" ]; then
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
    export no_proxy="localhost,127.0.0.1,.lan"
    export GIT_SSH_COMMAND='ssh -o "ProxyCommand=nc -X 5 -x localhost:7890 %h %p"'

    alias gfw='http_proxy= https_proxy= GIT_SSH_COMMAND='
fi


# aliases
alias v=${VISUAL}
alias tm='tmux new -As main'
alias del='trash'


# GitHub Copilot CLI
if command -v github-copilot-cli > /dev/null; then
    eval "$(github-copilot-cli alias -- "$0")"
fi



unset BREWPREFIX
