.PHONY: default Darwin Linux brew ohmyzsh rust link vim term clean patch_alacritty

default: $(shell uname)

Darwin: link vim term patch_alacritty

Linux: link vim

brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

ohmyzsh:
	curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

rust:
	curl -fsSf https://sh.rustup.rs | bash -s -- --no-modify-path

link:
	mkdir -p $(HOME)/.config
	ln -snf $(PWD)/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/p10k.zsh $(HOME)/.p10k.zsh
	ln -snf $(PWD)/nvim $(HOME)/.config/nvim
	ln -snf $(PWD)/tmux.conf $(HOME)/.tmux.conf
	mkdir -p $(HOME)/.config/brew
	ln -snf $(PWD)/Brewfile $(HOME)/.config/brew/Brewfile
	mkdir -p $(HOME)/.config/alacritty
	ln -snf $(PWD)/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml

ifeq ($(shell uname), Darwin)
	ln -snf $(PWD)/hammerspoon $(HOME)/.hammerspoon
endif

vim:
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

term:
	tic -x tmux-256color.terminfo

patch_alacritty:
	sh patch-alacritty.sh

clean:
	rm -f $(HOME)/.zshrc
	rm -f $(HOME)/.p10k.zsh
	rm -rf $(HOME)/.config/nvim
	rm -f $(HOME)/.tmux.conf
	rm -rf $(HOME)/.config/brew
	rm -rf $(HOME)/.config/alacritty
	rm -rf $(HOME)/.hammerspoon
