#!/usr/bin/env bash
set -euo pipefail

configure_sound() {
  read -rp "Do you want to install and configure PipeWire sound? SKIP THIS ON VM (y/N): " answer
  case "$answer" in
  [yY] | [yY][eE][sS])

    case "${PACKAGER:-pacman}" in
    pacman)
      "${ESCALATION_TOOL:-sudo}" pacman -S --needed --noconfirm \
        pipewire pipewire-alsa pipewire-pulse wireplumber alsa-utils
      ;;
    *)
      echo "Unsupported package manager: $PACKAGER"
      return 1
      ;;
    esac

    # Ensure user systemd session exists
    if loginctl show-user "$USER" | grep -q "Linger=no"; then
      echo "Enabling user lingering for proper systemd user session..."
      sudo loginctl enable-linger "$USER"
    fi

    export XDG_RUNTIME_DIR="/run/user/$(id -u)"

    systemctl --user daemon-reexec || true
    systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

    echo "PipeWire sound configured."
    ;;
  *)
    echo "Skipping sound configuration."
    ;;
  esac
}

configure_tlp() {
  read -rp "Install and configure TLP (recommended for laptops)? (y/N): " answer
  case "$answer" in
  [yY] | [yY][eE][sS])

    case "${PACKAGER:-pacman}" in
    pacman)
      "${ESCALATION_TOOL:-sudo}" pacman -S --needed --noconfirm tlp tlp-rdw
      ;;
    *)
      echo "Unsupported package manager: $PACKAGER"
      return 1
      ;;
    esac

    sudo systemctl mask power-profiles-daemon.service 2>/dev/null || true

    sudo systemctl enable --now tlp.service

    sudo tlp start

    echo "TLP configured. Current status:"
    tlp-stat -s
    ;;
  *)
    echo "Skipping TLP setup."
    ;;
  esac
}

echo "Ensuring pipx path..."
pipx ensurepath || true

configure_sound
configure_tlp

echo "Installing new bashrc..."
cp -f ~/.local/share/dwm-wattox/.bashrc ~/.bashrc
source ~/.bashrc
echo
echo "IMPORTANT:"
echo "Restart your shell or run:"
echo "  source ~/.bashrc"
echo "Setup complete."

SETUP_DIR="$HOME/arch-setup"
rm -rf "$SETUP_DIR"

rm -- "$0"
