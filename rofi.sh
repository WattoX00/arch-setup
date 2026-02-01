#!/bin/sh -e

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
