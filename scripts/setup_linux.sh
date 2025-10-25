sudo apt update && sudo apt upgrade -y
sudo apt install -y \
df vim \
  neovim \
  wget \
  unzip \
  htop \
  tmux \
  bat \
  fzf \
  ripgrep \
  zsh \
  tree \
  jq \
  rsync \

sudo apt install -y python3 python3-pip

sudo apt install syncthing
systemctl --user enable syncthing
systemctl --user start syncthing

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install csvlens
#
# install pyenv
curl -fsSL https://pyenv.run | bash
