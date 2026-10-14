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

# --- 3. .zshrc 設定 (既に存在する行は追記しない) ---
add_to_zshrc() {
    grep -qxF -- "$1" ~/.zshrc 2>/dev/null || echo "$1" >> ~/.zshrc
}
add_to_zshrc 'set -o vi'
# fzfの補完とバインドを有効化 (Brew版の推奨設定)
add_to_zshrc 'source <(fzf --zsh)'

source ~/.zshrc
echo "MacOS setup complete!"
