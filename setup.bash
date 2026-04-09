#!/usr/bin/env bash

# 1. OSとアーキテクチャの判別
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
else
    IS_MACOS=false
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  BAT_ARCH="amd64" ;;
        aarch64|arm64) BAT_ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
fi

# 2. パッケージインストール
if [ "$IS_MACOS" = true ]; then
    echo "Installing tools for MacOS via Homebrew..."
    # MacOSはbrewで一括（fzfもbrewで最新が入る）
    brew install vim tmux bat fzf
else
    echo "Installing tools for Ubuntu..."
    sudo apt update
    sudo apt install -y vim tmux curl grep

    # batの最新版をGitHubから取得
    echo "Installing latest 'bat' for $BAT_ARCH..."
    BAT_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_${BAT_ARCH}.deb"
    curl -LO "$URL"
    sudo dpkg -i "bat_${BAT_VERSION}_${BAT_ARCH}.deb"
    rm "bat_${BAT_VERSION}_${BAT_ARCH}.deb"

    # fzfをgitからインストール (Ubuntu 22.04の古いバージョン回避)
    if [ ! -d "$HOME/.fzf" ]; then
        echo "Cloning fzf for Ubuntu..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    # シェルに関わらず~/.zshrcと~/.bashrcの両方に設定を書き込む
    ~/.fzf/install --all
fi

# 3. vim-plug のインストール
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 4. Dotfiles のクローンとリンク
if [ ! -d "$HOME/dotfiles" ]; then
    git clone https://github.com/Ushiki/dotfiles.git ~/dotfiles
fi

ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.tmux.confg ~/.tmux.conf

# 5. Vimプラグインの自動インストール
echo "Installing Vim plugins..."
vim +PlugInstall +qall

# 6. シェル設定の反映
# $SHELLがzshを指しているか、zshrcが存在すればzshを優先
if [[ "$SHELL" == *"zsh"* ]] || [ -f "$HOME/.zshrc" ]; then
    CONF_FILE="$HOME/.zshrc"
else
    CONF_FILE="$HOME/.bashrc"
fi

# set -o vi の追記
grep -qxF 'set -o vi' "$CONF_FILE" || echo 'set -o vi' >> "$CONF_FILE"

# Ubuntuの場合にbatがbatcatとして入った場合の保険（GitHub版なら通常不要だが念のため）
if [ "$IS_MACOS" = false ]; then
    if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
        grep -q "alias bat='batcat'" "$CONF_FILE" || echo "alias bat='batcat'" >> "$CONF_FILE"
    fi
fi

# 設定の反映
source "$CONF_FILE"

echo "Setup complete!"
