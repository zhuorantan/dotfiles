default: all

all: link vim plugins

link:
	ln -snf $(PWD)/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/p10k.zsh $(HOME)/.p10k.zsh
	ln -snf $(PWD)/nvim $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim
	ln -snf $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -snf $(PWD)/hammerspoon $(HOME)/.hammerspoon

vim:
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

term:
	tic -x tmux-256color.terminfo

clean:
	rm -f $(HOME)/.zshrc
	rm -f $(HOME)/.p10k.zsh
	rm -rf $(or ${XDG_CONFIG_HOME}, ${HOME}/.config)/nvim
	rm -f $(HOME)/.tmux.conf
	rm -rf $(HOME)/.hammerspoon

.PHONY: default all link vim term clean
