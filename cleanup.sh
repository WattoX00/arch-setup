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

pipx ensurepath || true

configure_sound

SETUP_DIR="$HOME/arch-setup"
if [ -d "$SETUP_DIR" ]; then
  rm -rf "$SETUP_DIR"
fi

rm -- "$0"
