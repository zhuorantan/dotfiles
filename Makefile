.PHONY: default brew ohmyzsh link tmux clean

default: link tmux

brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

ohmyzsh:
	curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

link:
	ln -snf $(PWD)/zsh/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/zsh/zshenv $(HOME)/.zshenv
	ln -snf $(PWD)/zsh/zprofile $(HOME)/.zprofile
	ln -snf $(PWD)/git/gitconfig $(HOME)/.gitconfig
	ln -snf $(PWD)/git/gitignore $(HOME)/.gitignore
	ln -snf $(PWD)/zsh/p10k.zsh $(HOME)/.p10k.zsh
	mkdir -p $(HOME)/.config
	ln -snf $(PWD)/nvim $(HOME)/.config/nvim
	ln -snf $(PWD)/yazi $(HOME)/.config/yazi
	ln -snf $(PWD)/sesh $(HOME)/.config/sesh
	ln -snf $(PWD)/tmux/tmux.conf $(HOME)/.tmux.conf
	mkdir -p $(HOME)/.local/bin
	ln -snf $(PWD)/tmux/worktree.sh $(HOME)/.local/bin/wt
	mkdir -p $(HOME)/.codex/bin
	ln -snf $(PWD)/codex/bin/tmux-notify.sh $(HOME)/.codex/bin/tmux-notify.sh
ifeq ($(shell uname -s), Darwin)
	mkdir -p $(HOME)/.config/ghostty
	ln -snf $(PWD)/ghostty $(HOME)/.config/ghostty/config
	ln -snf $(PWD)/hammerspoon $(HOME)/.hammerspoon
endif
	@if [ -f private/Makefile ]; then $(MAKE) -C private link; fi

tmux:
	mkdir -p $(HOME)/.config/tmux/plugins/catppuccin
	rm -rf $(HOME)/.config/tmux/plugins/catppuccin/tmux
	git clone -b v2.3.0 https://github.com/catppuccin/tmux.git $(HOME)/.config/tmux/plugins/catppuccin/tmux

clean:
	rm -f $(HOME)/.zshrc
	rm -f $(HOME)/.zshenv
	rm -f $(HOME)/.zprofile
	rm -f $(HOME)/.gitconfig
	rm -f $(HOME)/.gitignore
	rm -f $(HOME)/.p10k.zsh
	rm -rf $(HOME)/.config/nvim
	rm -rf $(HOME)/.config/yazi
	rm -rf $(HOME)/.config/sesh
	rm -f $(HOME)/.tmux.conf
	rm -f $(HOME)/.local/bin/wt
	rm -f $(HOME)/.codex/bin/tmux-notify.sh
	rm -rf $(HOME)/.config/tmux
	rm -rf $(HOME)/.config/ghostty
	rm -rf $(HOME)/.hammerspoon
	@if [ -f private/Makefile ]; then $(MAKE) -C private clean; fi
