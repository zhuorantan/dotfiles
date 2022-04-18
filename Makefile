default: link vim term

link:
	mkdir -p $(HOME)/.config
	ln -snf $(PWD)/zshrc $(HOME)/.zshrc
	ln -snf $(PWD)/p10k.zsh $(HOME)/.p10k.zsh
	ln -snf $(PWD)/nvim $(HOME)/.config/nvim
	ln -snf $(PWD)/tmux.conf $(HOME)/.tmux.conf
	mkdir $(HOME)/.config/brew
	ln -snf $(PWD)/Brewfile $(HOME)/.config/brew/Brewfile
	mkdir $(HOME)/.config/alacritty
	ln -snf $(PWD)/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml

ifeq ($(shell uname), Darwin)
	ln -snf $(PWD)/hammerspoon $(HOME)/.hammerspoon
endif

vim:
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

term:
	tic -x tmux-256color.terminfo

clean:
	rm -f $(HOME)/.zshrc
	rm -f $(HOME)/.p10k.zsh
	rm -rf $(HOME)/.config/nvim
	rm -f $(HOME)/.tmux.conf
	rm -rf $(HOME)/.config/brew
	rm -rf $(HOME)/.config/alacritty
	rm -rf $(HOME)/.hammerspoon

.PHONY: default link vim term clean
