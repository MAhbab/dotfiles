#!/bin/bash
# setup.sh: Bootstraps a new macOS or Debian-based system with dotfiles dependencies.

set -euo pipefail

echo "Starting dotfiles setup script..."

# Function to check if a command exists
command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------------------------- #
#                                OS Detection                                  #
# ---------------------------------------------------------------------------- #
OS="$(uname)"
PACKAGE_MANAGER="" # Will store "brew" or "apt"

if [[ "${OS}" == "Darwin" ]]; then
  echo "Detected macOS."
  PACKAGE_MANAGER="brew"
elif [[ "${OS}" == "Linux" ]]; then
  # Check for Debian-based systems
  if command_exists apt-get; then
    echo "Detected Debian-based Linux."
    PACKAGE_MANAGER="apt"
  else
    echo "Unsupported Linux distribution. Exiting."
    exit 1
  fi
else
  echo "Unsupported operating system: ${OS}. Exiting."
  exit 1
fi

# ---------------------------------------------------------------------------- #
#                           Install Package Managers                           #
# ---------------------------------------------------------------------------- #

if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
  echo "Checking for Homebrew..."
  if ! command_exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Ensure brew is in PATH for the current session
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew is already installed."
    brew update || true # Update, but don't fail if update has issues (e.g. no new updates)
  fi
elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
  echo "Updating apt repositories..."
  sudo apt update
  # No specific package manager to install like Homebrew, apt is native
fi

# ---------------------------------------------------------------------------- #
#                              Install Zsh                                     #
# ---------------------------------------------------------------------------- #
echo "Checking for Zsh..."
if ! command_exists zsh; then
  echo "Installing Zsh..."
  if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
    brew install zsh
  elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
    sudo apt install -y zsh
  fi
  echo "Zsh installed."
else
  echo "Zsh is already installed."
fi

# Set Zsh as default shell (if not already)
echo "Checking if Zsh is the default login shell..."
if command_exists zsh; then
  CURRENT_LOGIN_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"
  ZSH_PATH="$(command -v zsh)"

  if [[ "${CURRENT_LOGIN_SHELL}" != "${ZSH_PATH}" ]]; then
    echo "Setting Zsh as default login shell..."
    if command_exists chsh; then
      # chsh requires the user's password, so this might prompt the user
      chsh -s "${ZSH_PATH}"
      echo "Zsh set as default login shell. Please log out and back in for changes to take effect."
    else
      echo "chsh command not found. Please set Zsh as your default login shell manually (e.g., 'chsh -s $(which zsh)')."
    fi
  else
    echo "Zsh is already the default login shell."
  fi
else
  echo "Zsh is not installed. Skipping default shell configuration."
fi

# ---------------------------------------------------------------------------- #
#                               Install Core Tools                             #
# ---------------------------------------------------------------------------- #

install_package() {
  local tool_name="$1"
  local brew_package="${2:-$tool_name}"
  local apt_package="${3:-$tool_name}"

  echo "Checking for ${tool_name}..."
  if ! command_exists "${tool_name}"; then
    echo "Installing ${tool_name}..."
    if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
      brew install "${brew_package}"
    elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
      sudo apt install -y "${apt_package}"
    fi
    echo "${tool_name} installed."
  else
    echo "${tool_name} is already installed."
  fi
}

install_package "git"
install_package "neovim"
install_package "tmux"
install_package "bat"
install_package "ripgrep"
install_package "jq"
echo "Checking for fzf..."
if ! command_exists fzf; then
  echo "Installing fzf..."
  if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
    brew install fzf
    # Run fzf's install script for key bindings, completions, etc.
    "$(brew --prefix)/opt/fzf/install" --all || true
  elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
    sudo apt install -y fzf fzf-tmux # fzf-tmux provides extra features/integration
    echo "For fzf shell integration (key bindings, completions) on Linux, check your distribution's documentation or run 'fzf --no-bash --no-zsh --no-fish' for instructions."
  fi
else
  echo "fzf is already installed."
fi

# Python and pip
echo "Checking for Python3 and pip3..."
if ! command_exists python3; then
  echo "Installing Python3 and pip3..."
  if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
    brew install python
  elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
    sudo apt install -y python3 python3-pip
  fi
  echo "Python3 and pip3 installed."
else
  echo "Python3 is already installed."
  # Check for pip3 separately, as it might not be immediately available in PATH
  # if python3 was already installed but pip3 wasn't or path not refreshed.
  if ! command_exists pip3; then
    echo "pip3 not found, attempting to install..."
    if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
      echo "pip3 should be installed with Homebrew's Python. Please ensure your PATH is correctly set after brew install python."
    elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
      sudo apt install -y python3-pip
    fi
  else
    echo "pip3 is already installed."


  fi
  fi

# pyenv installation
echo "Checking for pyenv..."
if ! command_exists pyenv; then
  echo "Installing pyenv and dependencies..."
  if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
    brew install pyenv
  elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
    # Install build dependencies for Python compilation
    sudo apt update
    sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    # Install pyenv using pyenv-installer
    curl https://pyenv.run | bash
  fi
  echo "pyenv installed."
else
  echo "pyenv is already installed."
fi

# pyenv initialization (must be sourced for pyenv commands to work)
if ! grep -q 'eval "$(pyenv init --path)"' "${HOME}/.zprofile"; then
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "${HOME}/.zprofile"
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "${HOME}/.zprofile"
  echo 'eval "$(pyenv init --path)"' >> "${HOME}/.zprofile"
  echo 'eval "$(pyenv virtualenv-init -)"' >> "${HOME}/.zprofile"
  echo "pyenv initialization added to ~/.zprofile. Please restart your shell or source ~/.zprofile."
  # Source for current shell session
  export PYENV_ROOT="$HOME/.pyenv"
  command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

PYTHON_VERSION="3.10.13"
OMNI_ENV_NAME="omni"

echo "Checking for Python ${PYTHON_VERSION} via pyenv..."
if ! pyenv versions | grep -q "${PYTHON_VERSION}"; then
  echo "Installing Python ${PYTHON_VERSION} via pyenv..."
  pyenv install "${PYTHON_VERSION}"
  echo "Python ${PYTHON_VERSION} installed."
else
  echo "Python ${PYTHON_VERSION} is already installed via pyenv."
fi

echo "Checking for pyenv virtual environment '${OMNI_ENV_NAME}'..."
if ! pyenv virtualenvs | grep -q "${OMNI_ENV_NAME}"; then
  echo "Creating pyenv virtual environment '${OMNI_ENV_NAME}' for Python ${PYTHON_VERSION}..."
  pyenv virtualenv "${PYTHON_VERSION}" "${OMNI_ENV_NAME}"
  echo "pyenv virtual environment '${OMNI_ENV_NAME}' created."
else
  echo "pyenv virtual environment '${OMNI_ENV_NAME}' already exists."
fi

# Node.js and npm
echo "Checking for Node.js and npm..."
if ! command_exists node; then
  echo "Installing Node.js and npm..."
  if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
    brew install node
  elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
    sudo apt install -y nodejs npm
  fi
  echo "Node.js and npm installed."
else
  echo "Node.js is already installed."
fi

# gemini-cli
echo "Checking for gemini-cli..."
if ! command_exists gemini; then
  echo "Installing gemini-cli..."
  if command_exists npm; then
    sudo npm install -g @google/gemini-cli
  else
    echo "npm not found. Please install Node.js and npm first to install gemini-cli."
  fi
  echo "gemini-cli installed."
else
  echo "gemini-cli is already installed."
fi

# gcloud-cli
echo "Checking for gcloud-cli..."
if ! command_exists gcloud; then
  echo "Installing gcloud-cli..."
  if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
    brew install google-cloud-sdk
  elif [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt update
    sudo apt install -y google-cloud-sdk
  fi
  echo "gcloud-cli installed."
else
  echo "gcloud-cli is already installed."
fi

# Rust (rustup)
echo "Checking for Rust (rustup)..."
if ! command_exists cargo; then
  echo "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Ensure cargo's bin directory is added to PATH for the current session
  source "$HOME/.cargo/env"
  echo "Rust installed. Consider adding 'source \"$HOME/.cargo/env\"' to your shell profile if it's not already there."
else
  echo "Rust is already installed."
fi

echo "Dotfiles setup script finished."

curl https://install.duckdb.org | sh
cargo install csvlens
touch ~/.zshrc.local
