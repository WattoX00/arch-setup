#!/usr/bin/env bash
# sddm.sh - SDDM on X11 + astronaut theme + dwm session entry.
# Sourced by dwm-wattox.sh, so it relies on common-script.sh
# ($ESCALATION_TOOL, $RC, $RED, $GREEN, $YELLOW).

SDDM_THEME_NAME="sddm-astronaut-theme"
SDDM_THEME_REPO="https://github.com/Keyitdev/sddm-astronaut-theme.git"
SDDM_THEME_DIR="/usr/share/sddm/themes/$SDDM_THEME_NAME"
# Variant = file name (without .conf) in the theme's Themes/ folder.
# Available: astronaut, black_hole, cyberpunk, hyprland_kath, jake_the_dog,
# japanese_aesthetic, pixel_sakura, pixel_sakura_static,
# post-apocalyptic_hacker, purple_leaves
SDDM_THEME_VARIANT="${SDDM_THEME_VARIANT:-japanese_aesthetic}"

installSddmPackages() {
  printf "%b\n" "${YELLOW}Installing SDDM and theme dependencies...${RC}"
  "$ESCALATION_TOOL" pacman -S --needed --noconfirm \
    sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg qt6-5compat qt6-declarative
}

installSddmTheme() {
  printf "%b\n" "${YELLOW}Installing SDDM theme: $SDDM_THEME_NAME ($SDDM_THEME_VARIANT)...${RC}"

  # Always start from a clean copy so re-running the script is safe.
  "$ESCALATION_TOOL" rm -rf "$SDDM_THEME_DIR"
  "$ESCALATION_TOOL" git clone -b master --depth 1 "$SDDM_THEME_REPO" "$SDDM_THEME_DIR" || {
    printf "%b\n" "${RED}Failed to clone the SDDM theme.${RC}"
    return 1
  }

  # The theme ships its own fonts.
  if [ -d "$SDDM_THEME_DIR/Fonts" ]; then
    "$ESCALATION_TOOL" cp -r "$SDDM_THEME_DIR/Fonts/." /usr/share/fonts/
    "$ESCALATION_TOOL" fc-cache -f
  fi

  # Pick the variant (fall back to the default if the name is wrong).
  if [ ! -f "$SDDM_THEME_DIR/Themes/${SDDM_THEME_VARIANT}.conf" ]; then
    printf "%b\n" "${YELLOW}Variant '$SDDM_THEME_VARIANT' not found, using 'astronaut'.${RC}"
    SDDM_THEME_VARIANT="astronaut"
  fi
  "$ESCALATION_TOOL" sed -i "s|^ConfigFile=.*|ConfigFile=Themes/${SDDM_THEME_VARIANT}.conf|" \
    "$SDDM_THEME_DIR/metadata.desktop"
}

configureSddm() {
  printf "%b\n" "${YELLOW}Configuring SDDM (X11)...${RC}"
  "$ESCALATION_TOOL" mkdir -p /etc/sddm.conf.d

  # A drop-in is safer than editing /etc/sddm.conf directly.
  "$ESCALATION_TOOL" tee /etc/sddm.conf.d/10-wattox.conf >/dev/null <<EOF
[General]
DisplayServer=x11
InputMethod=qtvirtualkeyboard

[Theme]
Current=$SDDM_THEME_NAME
EOF
}

installDwmSession() {
  printf "%b\n" "${YELLOW}Installing dwm session (SDDM entry + launcher)...${RC}"

  # SDDM does NOT read ~/.xinitrc. This launcher makes SDDM and startx share
  # one startup file: it runs ~/.xinitrc if there is one, else plain dwm.
  # Output goes to ~/.cache/dwm-session.log (overwritten each login).
  "$ESCALATION_TOOL" tee /usr/local/bin/dwm-session >/dev/null <<'EOF'
#!/bin/sh
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/dwm-session.log"
mkdir -p "$(dirname "$LOG")"
exec >"$LOG" 2>&1
echo "=== dwm session started $(date) ==="
if [ -x "$HOME/.xinitrc" ]; then
  exec "$HOME/.xinitrc"
elif [ -f "$HOME/.xinitrc" ]; then
  exec sh "$HOME/.xinitrc"
fi
exec dwm
EOF
  "$ESCALATION_TOOL" chmod 755 /usr/local/bin/dwm-session

  # SDDM lists whatever is in /usr/share/xsessions. Always (re)write it so the
  # entry uses the launcher even if a stock dwm.desktop exists.
  "$ESCALATION_TOOL" mkdir -p /usr/share/xsessions
  "$ESCALATION_TOOL" tee /usr/share/xsessions/dwm.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=dwm
Comment=Dynamic window manager
Exec=/usr/local/bin/dwm-session
Icon=dwm
Type=XSession
EOF
}

enableSddm() {
  # --force replaces any other display manager already enabled.
  "$ESCALATION_TOOL" systemctl enable --force sddm.service
  printf "%b\n" "${GREEN}SDDM enabled. It will start on next boot.${RC}"
}

setupSddm() {
  installSddmPackages || return 1
  installSddmTheme
  configureSddm
  installDwmSession
  enableSddm
}
