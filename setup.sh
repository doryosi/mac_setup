#!/usr/bin/env bash

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Install Homebrew only when it is not already installed.
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make Homebrew available in this script on both Apple Silicon and Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

install_formula() {
  if ! brew list --formula "$1" >/dev/null 2>&1; then
    brew install "$1"
  fi
}

install_cask() {
  if ! brew list --cask "$1" >/dev/null 2>&1; then
    brew install --cask "$1"
  fi
}

add_to_zshrc() {
  local line="$1"
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"

  touch "$zshrc"
  if ! grep -Fqx "$line" "$zshrc"; then
    echo "$line" >> "$zshrc"
  fi
}

configure_orca_keybindings() {
  local keybindings_file="$HOME/.orca/keybindings.json"

  # Keep existing Orca customizations intact; this is only the initial default.
  if [[ ! -e "$keybindings_file" ]]; then
    mkdir -p "$(dirname "$keybindings_file")"
    cat > "$keybindings_file" <<'EOF'
{
  "tab.nextAllTypes": ["Mod+Alt+ArrowRight"],
  "tab.previousAllTypes": ["Mod+Alt+ArrowLeft"]
}
EOF
  fi
}

configure_opencode() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  local config_file="$config_dir/opencode.json"
  local tui_file="$config_dir/tui.json"

  mkdir -p "$config_dir"

  # Keep existing OpenCode customizations intact; these are initial defaults.
  if [[ ! -e "$config_file" ]]; then
    cp "$script_dir/config/opencode/opencode.json" "$config_file"
  fi

  if [[ ! -e "$tui_file" ]]; then
    cp "$script_dir/config/opencode/tui.json" "$tui_file"
  fi
}

configure_vscode() {
  local user_dir="$HOME/Library/Application Support/Code/User"
  local settings_file="$user_dir/settings.json"
  local extensions_file="$script_dir/config/vscode/extensions.txt"
  local extension

  mkdir -p "$user_dir"
  if [[ ! -e "$settings_file" ]]; then
    cp "$script_dir/config/vscode/settings.json" "$settings_file"
  fi

  while IFS= read -r extension; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    code --install-extension "$extension"
  done < "$extensions_file"
}

# Desktop applications.
install_cask iterm2
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
install_cask alt-tab
install_cask visual-studio-code
configure_vscode
install_cask hiddenbar
install_cask chatgpt
install_cask rectangle
install_cask font-meslo-lg-nerd-font
install_cask ghostty
# Obsidian also installs its `obsidian` CLI binary.
install_cask obsidian
install_cask linear
configure_orca_keybindings

# Ghostty: Cmd+I prompts for the current terminal window title.
ghostty_config="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
mkdir -p "$(dirname "$ghostty_config")"
if [[ ! -e "$ghostty_config" ]]; then
  cp "$script_dir/config/ghostty.conf" "$ghostty_config"
fi
if ! grep -Fqx 'keybind = cmd+i=prompt_surface_title' "$ghostty_config" 2>/dev/null; then
  echo 'keybind = cmd+i=prompt_surface_title' >> "$ghostty_config"
fi
# Keep the macOS Dock attention/badge behavior when a terminal rings the bell.
if ! grep -Fqx 'bell-features = attention,title' "$ghostty_config" 2>/dev/null; then
  echo 'bell-features = attention,title' >> "$ghostty_config"
fi

# Configure Rectangle shortcuts. `maximize` fills the current display without
# entering macOS Full Screen mode or creating a separate Space.
# Ctrl+Cmd = modifierFlags 1310720; arrow key codes: left 123, right 124,
# up 126, down 125; F = 3 and C = 8.
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle maximize '{keyCode = 3; modifierFlags = 1310720;}'
defaults write com.knollsoft.Rectangle centerHalf '{keyCode = 8; modifierFlags = 1310720;}'
defaults write com.knollsoft.Rectangle leftHalf '{keyCode = 123; modifierFlags = 1310720;}'
defaults write com.knollsoft.Rectangle rightHalf '{keyCode = 124; modifierFlags = 1310720;}'
defaults write com.knollsoft.Rectangle topHalf '{keyCode = 126; modifierFlags = 1310720;}'
defaults write com.knollsoft.Rectangle bottomHalf '{keyCode = 125; modifierFlags = 1310720;}'
if pgrep -x Rectangle >/dev/null 2>&1; then
  killall Rectangle
  sleep 1
  open -a Rectangle
fi

# Shell plugins and tools.
install_formula zsh-autosuggestions
add_to_zshrc 'source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh'

install_formula zsh-syntax-highlighting
add_to_zshrc 'source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

install_formula fzf
add_to_zshrc 'source <(fzf --zsh)'

install_formula eza
add_to_zshrc "alias ll='eza -l --icons --git'"

install_formula starship
starship_config="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
if [[ ! -f "$starship_config" ]]; then
  mkdir -p "$(dirname "$starship_config")"
  cp "$script_dir/config/starship.toml" "$starship_config"
fi
add_to_zshrc 'eval "$(starship init zsh)"'

# OpenCode command-line agent.
install_formula opencode
install_formula node
configure_opencode
bash "$script_dir/skills.sh"

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# Development and container tools.
install_formula docker
install_formula kind
install_formula go
install_formula k9s
