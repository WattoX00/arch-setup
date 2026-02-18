#!/usr/bin/env bash
set -e

configure_sound() {
  read -rp "Do you want to install and configure PipeWire sound? SKIP THIS ON PC (y/N): " answer
  case "$answer" in
  [yY] | [yY][eE][sS])
    case "$PACKAGER" in
    pacman)
      "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm \
        pipewire pipewire-alsa pipewire-pulse wireplumber alsa-utils
      ;;
    *)
      echo "Unsupported package manager: $PACKAGER"
      return 1
      ;;
    esac

    systemctl --user enable --now pipewire
    systemctl --user enable --now pipewire-pulse
    systemctl --user enable --now wireplumber

    echo "PipeWire sound configured."
    ;;
  *)
    echo "Skipping sound configuration."
    ;;
  esac
}

# Ensure pipx path
pipx ensurepath || true

# Configure sound if requested
configure_sound

# Remove setup directory if it exists
SETUP_DIR="$HOME/arch-setup"
if [ -d "$SETUP_DIR" ]; then
  rm -rf "$SETUP_DIR"
fi

# Remove this script
rm -- "$0"
