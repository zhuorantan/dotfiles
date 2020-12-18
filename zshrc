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
    export FZF_DEFAULT_COMMAND="fd -I --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="fd --type d -I --hidden --follow --exclude .git"
else
    export FZF_DEFAULT_COMMAND="fdfind -I --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="fdfind --type d -I --hidden --follow --exclude .git"
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


# aliases
alias rm='rm -i'
alias ss='http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890'
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


# M1 Mac
if [ "$(uname)" = "Darwin" ]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH"
    alias i='arch -x86_64'
    alias ibrew='arch -x86_64 /usr/local/bin/brew'
fi

