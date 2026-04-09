#!/usr/bin/env bash
#!/bin/bash
# Ubuntu Setup Script (Target: bash)

# --- 1. 環境判定 ---
HAS_SUDO=$(sudo -n true 2>/dev/null && echo true || echo false)
RAW_ARCH=$(uname -m)
BAT_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# アーキテクチャ名の変換
if [ "$RAW_ARCH" = "x86_64" ]; then
    DEB_ARCH="amd64"
    TAR_ARCH="x86_64"
else
    DEB_ARCH="arm64"
    TAR_ARCH="aarch64"
fi

# --- 2. ツールインストール ---
if [ "$HAS_SUDO" = true ]; then
    echo "Installing tools via apt (sudo)..."
    sudo apt update
    sudo apt install -y vim tmux curl grep git
    # bat (deb版)
    URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_${DEB_ARCH}.deb"
    curl -LO "$URL"
    sudo dpkg -i "bat_${BAT_VERSION}_${DEB_ARCH}.deb" && rm "bat_${BAT_VERSION}_${DEB_ARCH}.deb"
else
    echo "No sudo. Checking pre-installed tools..."
    for tool in vim tmux curl grep git; do
        command -v $tool &> /dev/null || { echo "Error: $tool not found."; exit 1; }
    done
    # bat (musl版を $HOME/.bat へ)
    if ! command -v bat &> /dev/null; then
        echo "Installing bat (musl) to $HOME/.bat..."
        BAT_NAME="bat-v${BAT_VERSION}-${TAR_ARCH}-unknown-linux-musl"
        URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/${BAT_NAME}.tar.gz"
        
        curl -LO "$URL"
        tar -xvf "${BAT_NAME}.tar.gz"
        mkdir -p "$HOME/.bat"
        mv "${BAT_NAME}/bat" "$HOME/.bat/"
        mv "${BAT_NAME}/autocomplete" "$HOME/.bat/"
        rm -rf "${BAT_NAME}" "${BAT_NAME}.tar.gz"
    fi
fi

# fzf (Ubuntuはgitからインストール)
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-zsh --no-fish
fi

# --- 3. Vim & Dotfiles ---
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
[ ! -d "$HOME/dotfiles" ] && git clone https://github.com/Ushiki/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.tmux.confg ~/.tmux.conf
vim +PlugInstall +qall

# --- 4. .bashrc 設定 ---
{
    echo 'set -o vi'
    [ -d "$HOME/.bat" ] && echo 'export PATH="$HOME/.bat:$PATH"'
    [ -f "$HOME/.bat/autocomplete/bat.bash" ] && echo "source $HOME/.bat/autocomplete/bat.bash"
} >> ~/.bashrc

echo "Ubuntu setup complete! Please run 'source ~/.bashrc'"

