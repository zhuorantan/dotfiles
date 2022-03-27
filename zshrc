# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# brew
BREWPREFIX="/opt/homebrew"
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/brew/Brewfile"
eval "$(${BREWPREFIX}/bin/brew shellenv)"

# python
export PATH="${BREWPREFIX}/opt/python/libexec/bin:${PATH}"
# ruby
export GEM_HOME="${BREWPREFIX}/lib/ruby/gems"
export PATH="${GEM_HOME}/bin:${BREWPREFIX}/opt/ruby/bin:${PATH}"
typeset -U PATH # remove duplicated entries in $PATH


# ohmyzsh
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z colored-man-pages history docker fzf)
source ${ZSH}/oh-my-zsh.sh
source ${BREWPREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${BREWPREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# powerlevel10k
source ${BREWPREFIX}/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# editor
if [ -z "${NVIM_LISTEN_ADDRESS}" ]; then
    export VISUAL="nvim"
else
    export VISUAL="nvr --remote-wait +'setlocal bufhidden=wipe'"
fi


# fzf
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
export FZF_DEFAULT_OPTS="--cycle --layout=reverse"


# proxy
if [ -n "$(netstat -anp tcp 2> /dev/null | grep -E '7890(.+)LISTEN')" ]; then
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
fi


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


# nvm
export NVM_DIR="${HOME}/.nvm"
[ -s "${BREWPREFIX}/opt/nvm/nvm.sh" ] && . "${BREWPREFIX}/opt/nvm/nvm.sh"  # This loads nvm
[ -s "${BREWPREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && . "${BREWPREFIX}/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

unset BREWPREFIX
