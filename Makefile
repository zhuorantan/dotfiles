default: all

all: link vim plugins

link:
	ln -snf $(PWD)/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/p10k.zsh $(HOME)/.p10k.zsh
	mkdir -p $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim
	ln -snf $(PWD)/vimrc $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/init.vim
	ln -snf $(PWD)/coc-settings.json $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/coc-settings.json
	ln -snf $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -snf $(PWD)/hammerspoon $(HOME)/.hammerspoon

vim:
	sh -c 'curl -fLo $(or ${XDG_DATA_HOME}, ${HOME}/.local/share)/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	nvim --headless +PlugInstall +qall!

plugins:
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

clean:
	rm -f $(HOME)/.zsh
	rm -f $(HOME)/.p10k.zsh
	rm -f $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/init.vim
	rm -f $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/coc-settings.json
	rm -f $(HOME)/.tmux.conf

.PHONY: default all link vim plugins clean

