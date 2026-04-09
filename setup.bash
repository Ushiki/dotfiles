#!/usr/bin/env bash
# Ubuntu Setup Script (Target: bash)

# --- 1. 環境判定 ---
HAS_SUDO=$(sudo -n true 2>/dev/null && echo true || echo false)
ARCH=$(uname -m) # x86_64 or aarch64
# 最新のバージョンタグ(v付き)を取得 (例: v0.24.0)
BAT_TAG=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
# vを除いたバージョン数値を取得 (例: 0.24.0)
BAT_VER="${BAT_TAG#v}"

# --- 2. ツールインストール ---
if [ "$HAS_SUDO" = true ]; then
    echo "Installing tools via apt (sudo)..."
    sudo apt update
    sudo apt install -y vim tmux curl grep git
    
    # deb用のアーキテクチャ名変換
    DEB_ARCH=$(echo "$ARCH" | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    # パターン: bat_0.24.0_amd64.deb
    URL="https://github.com/sharkdp/bat/releases/download/${BAT_TAG}/bat_${BAT_VER}_${DEB_ARCH}.deb"
    
    curl -LO "$URL"
    sudo dpkg -i "bat_${BAT_VER}_${DEB_ARCH}.deb" && rm "bat_${BAT_VER}_${DEB_ARCH}.deb"
else
    echo "No sudo. Using pre-installed tools..."
    for tool in vim tmux curl grep git; do
        command -v $tool &> /dev/null || { echo "Error: $tool not found."; exit 1; }
    done

    # bat (tar.gz版) を $HOME/.bat へ
    if ! command -v bat &> /dev/null; then
        echo "Installing bat for $ARCH to $HOME/.bat..."
        # パターン: bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
        BAT_NAME="bat-${BAT_TAG}-${ARCH}-unknown-linux-gnu"
        URL="https://github.com/sharkdp/bat/releases/download/${BAT_TAG}/${BAT_NAME}.tar.gz"
        
        curl -LO "$URL"
        tar -xvf "${BAT_NAME}.tar.gz"
        mkdir -p "$HOME/.bat"
        mv "${BAT_NAME}/bat" "$HOME/.bat/"
        mv "${BAT_NAME}/autocomplete" "$HOME/.bat/"
        rm -rf "${BAT_NAME}" "${BAT_NAME}.tar.gz"
    fi
fi

# fzf (Ubuntuはリポジトリが古いためgitから)
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
    if [ -d "$HOME/.bat" ]; then
        echo 'export PATH="$HOME/.bat:$PATH"'
        echo "source $HOME/.bat/autocomplete/bat.bash"
    fi
} >> ~/.bashrc

echo "Ubuntu setup complete! Run 'source ~/.bashrc' to reflect changes."


