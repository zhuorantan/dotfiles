# M1 Mac
if [ "$(uname)" = "Darwin" ] && [ "$(arch)" = "arm64" ]; then
    export FZF_BASE=/opt/homebrew/opt/fzf
fi


# Oh My ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git z colored-man-pages history docker fzf)

source $ZSH/oh-my-zsh.sh


# custom plugins
if [ "$(uname)" = "Darwin" ]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# environment variables
export EDITOR="nvim"

if [ "$(uname)" = "Darwin" ]; then
    export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
else
    export FZF_DEFAULT_COMMAND="fdfind --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="fdfind --type d --hidden --follow --exclude .git"
fi
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_DEFAULT_OPTS="--cycle --layout=reverse"

if [ "$(uname)" = "Darwin" ]; then
    # python
    export PATH="/usr/local/opt/python/libexec/bin:$PATH"
    # ruby
    export GEM_HOME="/usr/local/lib/ruby/gems"
    export PATH="/usr/local/opt/ruby/bin:$GEM_HOME/bin:$PATH"
else
    export PATH="$HOME/.local/bin:$PATH"
fi

typeset -U PATH # remove duplicated entries in $PATH

if [ -n "$(netstat -anp tcp 2> /dev/null | grep -E '7890(.+)LISTEN')" ]; then
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
fi


# aliases
alias rm='rm -i'
alias gfw='http_proxy= https_proxy='
alias vi='nvim'
alias v='vi'
alias tm='tmux attach || tmux new'

if [ -x "$(command -v trash)" ]; then
    alias del='trash'
fi
if [ -x "$(command -v leetcode)" ]; then
    alias lc='leetcode'
fi

if [ "$(uname)" = "Linux" ]; then
    alias python='python3'
    alias pip='pip3'
    alias fd='fdfind'
fi


# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


# M1 Mac
if [ "$(uname)" = "Darwin" ] && [ "$(arch)" = "arm64" ]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH"
    i() {
        arch -x86_64 $@
    }
    ibrew() {
        i /usr/local/bin/brew $@
    }
fi
