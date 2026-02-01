#!/bin/sh -e

setupAlacrittyConfig() {
    USER_HOME="$(getent passwd "$USER" | cut -d: -f6)"
    ALAC_DIR="$USER_HOME/.config/alacritty"

    printf "%b\n" "${YELLOW}Copying alacritty config files...${RC}"

    if [ -d "$ALAC_DIR" ] && [ ! -d "$ALAC_DIR-bak" ]; then
        cp -r "$ALAC_DIR" "$ALAC_DIR-bak"
    fi

    mkdir -p "$ALAC_DIR"

    curl -sSLo "$ALAC_DIR/alacritty.toml" \
        "https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/alacritty/alacritty.toml"

    curl -sSLo "$ALAC_DIR/keybinds.toml" \
        "https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/alacritty/keybinds.toml"

    curl -sSLo "$ALAC_DIR/nordic.toml" \
        "https://raw.githubusercontent.com/wattox00/dwm-wattox/main/config/alacritty/nordic.toml"

    printf "%b\n" "${GREEN}Alacritty configuration files copied.${RC}"
}
