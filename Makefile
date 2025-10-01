.PHONY: default brew ohmyzsh link tmux clean

default: link tmux

brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

ohmyzsh:
	curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

link:
	mkdir -p $(HOME)/.config
	ln -snf $(PWD)/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/p10k.zsh $(HOME)/.p10k.zsh
	ln -snf $(PWD)/nvim $(HOME)/.config/nvim
	ln -snf $(PWD)/tmux.conf $(HOME)/.tmux.conf
	mkdir -p $(HOME)/.config/brew
	ln -snf $(PWD)/Brewfile $(HOME)/.config/brew/Brewfile
	mkdir -p $(HOME)/.config/ghostty
	ln -snf $(PWD)/ghostty $(HOME)/.config/ghostty/config
	ln -snf $(PWD)/hammerspoon $(HOME)/.hammerspoon

tmux:
	mkdir -p $(HOME)/.config/tmux/plugins/catppuccin
	rm -rf $(HOME)/.config/tmux/plugins/catppuccin/tmux
	git clone -b v2.1.3 https://github.com/catppuccin/tmux.git $(HOME)/.config/tmux/plugins/catppuccin/tmux

clean:
	rm -f $(HOME)/.zshrc
	rm -f $(HOME)/.p10k.zsh
	rm -rf $(HOME)/.config/nvim
	rm -f $(HOME)/.tmux.conf
	rm -rf $(HOME)/.config/brew
	rm -rf $(HOME)/.config/ghostty
	rm -rf $(HOME)/.config/tmux
	rm -rf $(HOME)/.hammerspoon
