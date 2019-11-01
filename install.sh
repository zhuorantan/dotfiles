DIR=$(pwd)
ln -snf $DIR/zshrc ~/.zshrc
ln -snf $DIR/vimrc ~/.vimrc
ln -snf $DIR/ssh.conf ~/.ssh/config
ln -snf $DIR/nvim_init.vim ~/.config/nvim/init.vim
ln -snf $DIR/tmux.conf ~/.tmux.conf.local

if [[ "$(uname 2> /dev/null)" == "Darwin" ]]; then
    ln -snf $DIR/clash_config.yaml ~/.config/clash/config.yaml
fi
