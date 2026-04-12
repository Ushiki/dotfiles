#!/usr/bin/env bash
# Ubuntu Setup Script (Target: bash)

# --- 1. 環境判定 ---
HAS_SUDO=$(sudo -n true 2>/dev/null && echo true || echo false)
ARCH=$(uname -m) # x86_64 or aarch64
BAT_TAG=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "\K[^"]*')

# --- 2. ツールインストール (vim, tmux, etc.) ---
if [ "$HAS_SUDO" = true ]; then
    echo "Installing core tools via apt..."
    sudo apt update
    sudo apt install -y vim tmux curl grep git
else
    echo "Checking pre-installed tools..."
    for tool in vim tmux curl grep git; do
        command -v $tool &> /dev/null || { echo "Error: $tool not found."; exit 1; }
    done
fi

# --- 3. bat インストール (常に tar.gz を使用) ---
if ! command -v bat &> /dev/null; then
    echo "Installing bat (${BAT_TAG}) to $HOME/.bat..."
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

# --- 4. fzf インストール (git) ---
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-zsh --no-fish
fi

# --- 5. Vim & Dotfiles ---
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
[ ! -d "$HOME/dotfiles" ] && git clone https://github.com/Ushiki/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
vim +PlugInstall +qall

# --- 6. .bashrc 設定 ---
{
    echo 'set -o vi'
    echo 'export PATH="$HOME/.bat:$PATH"'
    echo "source $HOME/.bat/autocomplete/bat.bash"
} >> ~/.bashrc

echo "Ubuntu setup complete! Run 'source ~/.bashrc'"


