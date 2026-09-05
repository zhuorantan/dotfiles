# Preferred command paths. This file is sourced by both ~/.zshenv and
# ~/.zprofile so login shells restore this ordering after macOS path_helper.
typeset -U path PATH
typeset -a _preferred_paths

_preferred_paths=(
    "${HOME}/.local/bin"
)

if [[ -d "${HOME}/.bun/bin" ]]; then
    _preferred_paths+=("${HOME}/.bun/bin")
fi

if [[ -d /opt/homebrew/opt/ruby ]]; then
    _preferred_paths+=(
        "$(/opt/homebrew/opt/ruby/bin/ruby -r rubygems -e 'puts Gem.bindir')"
        /opt/homebrew/opt/ruby/bin
    )
fi

if [[ -d /opt/homebrew/opt/python ]]; then
    _preferred_paths+=(/opt/homebrew/opt/python/libexec/bin)
fi

if [[ -d /opt/homebrew/opt/rustup ]]; then
    _preferred_paths+=(/opt/homebrew/opt/rustup/bin)
fi

_preferred_paths+=(
    /opt/homebrew/bin
    /opt/homebrew/sbin
)
path=("${_preferred_paths[@]}" "${path[@]}")

unset _preferred_paths
