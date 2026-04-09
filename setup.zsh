#!/usr/bin/env zsh
# MacOS Setup Script (Target: zsh)

# --- 1. Homebrew確認 & インストール ---
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Install it first from https://brew.sh/"
    exit 1
fi

echo "Installing tools via Homebrew..."
brew install vim tmux bat fzf

# --- 2. Vim & Dotfiles ---
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
if [ ! -d "$HOME/dotfiles" ]; then
    git clone https://github.com/Ushiki/dotfiles.git ~/dotfiles
fi

ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.tmux.confg ~/.tmux.conf
vim +PlugInstall +qall

# --- 3. .zshrc 設定 ---
# fzfの補完とバインドを有効化 (Brew版の推奨設定)
{
    echo 'set -o vi'
    # Homebrew版fzfの初期化
    echo 'source <(fzf --zsh)'
} >> ~/.zshrc

source ~/.zshrc
echo "MacOS setup complete!"
