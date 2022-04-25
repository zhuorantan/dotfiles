# brew
BREWPREFIX="/opt/homebrew"
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/brew/Brewfile"
eval "$(${BREWPREFIX}/bin/brew shellenv)"


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
source "${HOME}/.cargo/env"
# python
export PATH="${BREWPREFIX}/opt/python/libexec/bin:${PATH}"
# ruby
export GEM_HOME="${BREWPREFIX}/lib/ruby/gems"
export PATH="${GEM_HOME}/bin:${BREWPREFIX}/opt/ruby/bin:${PATH}"

# nvm
if [ -s "${BREWPREFIX}/opt/nvm/nvm.sh" ]; then
    export NVM_DIR="${HOME}/.nvm"
    export PATH="${NVM_DIR}/versions/node/v16.14.2/bin:${PATH}"

    . "${BREWPREFIX}/opt/nvm/nvm.sh" --no-use
    [ -s "${BREWPREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && . "${BREWPREFIX}/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
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
source ${BREWPREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${BREWPREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# powerlevel10k
source ${BREWPREFIX}/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# aliases
alias gfw='http_proxy= https_proxy='
alias v=${VISUAL}
alias tm='tmux attach || tmux new'
alias del='trash'


if [ "$(uname)" = "Darwin" ]; then
    i() {
        arch -x86_64 $@
    }
fi


unset BREWPREFIX
