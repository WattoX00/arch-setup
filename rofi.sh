#!/bin/sh -e

installRofi() {
    if ! command_exists rofi; then
    printf "%b\n" "${YELLOW}Installing Rofi...${RC}"
        case "$PACKAGER" in
            pacman)
                "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm rofi
                ;;
            apk)
                "$ESCALATION_TOOL" "$PACKAGER" add rofi
                ;;
            xbps-install)
                "$ESCALATION_TOOL" "$PACKAGER" -Sy rofi  
                ;;
            *)
                "$ESCALATION_TOOL" "$PACKAGER" install -y rofi
                ;;
        esac
    else
        printf "%b\n" "${GREEN}Rofi is already installed.${RC}"
    fi
}

setupRofiConfig() {
    USER_HOME="$(getent passwd "$USER" | cut -d: -f6)"
    ROFI_DIR="$USER_HOME/.config/rofi"

    printf "%b\n" "${YELLOW}Copying alacritty config files...${RC}"

    if [ -d "$ROFI_DIR" ] && [ ! -d "$ROFI_DIR-bak" ]; then
        cp -r "$ROFI_DIR" "$ROFI_DIR-bak"
    fi


    mkdir -p "$ROFI_DIR"
    curl -sSLo "$ROFI_DIR/powermenu.sh" https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/rofi/powermenu.sh
    chmod +x "$ROFI_DIR/powermenu.sh"
    curl -sSLo "$ROFI_DIR/config.rasi" https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/rofi/config.rasi
    mkdir -p "$ROFI_DIR/themes"
    curl -sSLo "$ROFI_DIR/themes/nord.rasi" https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/rofi/themes/nord.rasi
    curl -sSLo "$ROFI_DIR/themes/sidetab-nord.rasi" https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/rofi/themes/sidetab-nord.rasi
    curl -sSLo "$ROFI_DIR/themes/powermenu.rasi" https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/rofi/themes/powermenu.rasi
}
