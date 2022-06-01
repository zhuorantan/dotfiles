# brew
BREWPREFIX="/opt/homebrew"
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/brew/Brewfile"
[[ ! -f "${BREWPREFIX}/bin/brew" ]] || eval "$(${BREWPREFIX}/bin/brew shellenv)"


# tmux
export ZSH_TMUX_AUTOSTART="true"
export ZSH_TMUX_DEFAULT_SESSION_NAME="main"


# fzf
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
export FZF_DEFAULT_OPTS="--cycle --layout=reverse"


# editor
if [ -z "${NVIM_LISTEN_ADDRESS}" ]; then
    export VISUAL="nvim"
else
    export VISUAL="nvim --server ${NVIM_LISTEN_ADDRESS} --remote"
fi
export MANPAGER="$VISUAL +Man! -"


# rust
[[ ! -f "${HOME}/.cargo/env" ]] || source "${HOME}/.cargo/env" 
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
if [ -d "${BREWPREFIX}/opt/node@16/bin" ]; then
    export PATH="${BREWPREFIX}/opt/node@16/bin:${PATH}"
fi

typeset -U PATH # remove duplicated entries in $PATH


# proxy
if [ -n "$(netstat -anp tcp 2> /dev/null | grep -E '7890(.+)LISTEN')" ]; then
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
fi


# ohmyzsh
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z colored-man-pages history docker fzf tmux)
source ${ZSH}/oh-my-zsh.sh

if [ -d "${BREWPREFIX}" ]; then
    source ${BREWPREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${BREWPREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${BREWPREFIX}/opt/powerlevel10k/powerlevel10k.zsh-theme
else
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi

# powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# aliases
alias gfw='http_proxy= https_proxy='
alias v=${VISUAL}
alias tm='tmux attach || tmux new'
alias del='trash'


unset BREWPREFIX
