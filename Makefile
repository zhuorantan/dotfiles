default: all

all: link vim

link:
	mkdir -p $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim
	ln -snf $(PWD)/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/p10k.zsh $(HOME)/.p10k.zsh
	ln -snf $(PWD)/vimrc $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/init.vim
	ln -snf $(PWD)/coc-settings.json $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/coc-settings.json
	ln -snf $(PWD)/tmux.conf $(HOME)/.tmux.conf

vim:
	sh -c 'curl -fLo $(or ${XDG_DATA_HOME}, ${HOME}/.config)/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	nvim --headless +PlugInstall +qall!

clean:
	rm -f $(HOME)/.zsh
	rm -f $(HOME)/.p10k.zsh
	rm -f $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/init.vim
	rm -f $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim/coc-settings.json
	rm -f $(HOME)/.tmux.conf

.PHONY: default all link vim clean

