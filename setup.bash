#!/usr/bin/env bash
# Ubuntu Setup Script (Target: bash)

# --- 1. 環境判定 ---
HAS_SUDO=$(sudo -n true 2>/dev/null && echo true || echo false)
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64\|arm64/arm64/')
BAT_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# --- 2. ツールインストール ---
if [ "$HAS_SUDO" = true ]; then
    echo "Installing tools via apt (sudo)..."
    sudo apt update
    sudo apt install -y vim tmux curl grep git
    # bat (deb版)
    curl -LO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_${ARCH}.deb"
    sudo dpkg -i "bat_${BAT_VERSION}_${ARCH}.deb" && rm "bat_${BAT_VERSION}_${ARCH}.deb"
else
    echo "No sudo. Checking pre-installed tools..."
    for tool in vim tmux curl grep git; do
        command -v $tool &> /dev/null || { echo "Error: $tool not found."; exit 1; }
    done
    # bat (バイナリ版を $HOME/.bat へ)
    if ! command -v bat &> /dev/null; then
        BAT_FILE="bat-v${BAT_VERSION}-${ARCH}-unknown-linux-gnu"
        curl -LO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/${BAT_FILE}.tar.gz"
        tar -xvf "${BAT_FILE}.tar.gz"
        mkdir -p "$HOME/.bat"
        mv "${BAT_FILE}/bat" "$HOME/.bat/"
        cp -r "${BAT_FILE}/autocomplete" "$HOME/.bat/"
        rm -rf "${BAT_FILE}" "${BAT_FILE}.tar.gz"
    fi
fi

# fzf (Ubuntuのリポジトリは古いためgitから)
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

source ~/.bashrc
echo "Ubuntu setup complete!"
