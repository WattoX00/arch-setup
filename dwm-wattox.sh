#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/common-script.sh"
. "$SCRIPT_DIR/common-service-script.sh"
. "$SCRIPT_DIR/alacritty.sh"
. "$SCRIPT_DIR/rofi.sh"
. "$SCRIPT_DIR/bibata.sh"
. "$SCRIPT_DIR/todol.sh"
. "$SCRIPT_DIR/nvim.sh"

setupDWM() {
    printf "%b\n" "${YELLOW}Installing DWM-Wattox...${RC}"
    case "$PACKAGER" in # Install pre-Requisites
        pacman)
            "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm base-devel libx11 libxinerama libxft imlib2 git unzip flameshot mate-polkit alsa-utils rofi alacritty xclip thunar tumbler gvfs thunar-archive-plugin dunst feh nwg-look xorg-xprop xorg-server xorg-xinit polybar picom xdg-user-dirs xdg-desktop-portal-gtk pipewire pavucontrol gnome-keyring flatpak networkmanager network-manager-applet python-pipx nvim
            ;;
        *)
            printf "%b\n" "${RED}Unsupported package manager: ""$PACKAGER""${RC}"
            exit 1
            ;;
    esac
}

makeDWM() {
    [ ! -d "$HOME/.local/share" ] && mkdir -p "$HOME/.local/share/"
    if [ ! -d "$HOME/.local/share/dwm-wattox" ]; then
	printf "%b\n" "${YELLOW}DWM-wattox not found, cloning repository...${RC}"
	cd "$HOME/.local/share/" && git clone https://github.com/WattoX00/dwm-wattox.git # CD to Home directory to install dwm-wattox This path can be changed (e.g. to linux-toolbox directory)
	cd dwm-wattox/ # Hardcoded path, maybe not the best.
    else
	printf "%b\n" "${GREEN}DWM-wattox directory already exists, replacing..${RC}"
	cd "$HOME/.local/share/dwm-wattox" && git pull
    fi
    "$ESCALATION_TOOL" make clean install # Run make clean install
}

install_nerd_font() {
    # Check to see if the MesloLGS Nerd Font is installed (Change this to whatever font you would like)
    FONT_NAME="MesloLGS Nerd Font Mono"
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    FONT_INSTALLED=$(fc-list | grep -i "Meslo")

    if [ -n "$FONT_INSTALLED" ]; then
        printf "%b\n" "${GREEN}Meslo Nerd-fonts are already installed.${RC}"
        return 0
    fi

    printf "%b\n" "${YELLOW}Installing Meslo Nerd-fonts${RC}"

    # Create the fonts directory if it doesn't exist
    if [ ! -d "$FONT_DIR" ]; then
          mkdir -p "$FONT_DIR" || {
            printf "%b\n" "${RED}Failed to create directory: $FONT_DIR${RC}"
            return 1
        }
    fi
        printf "%b\n" "${YELLOW}Installing font '$FONT_NAME'${RC}"
        # Change this URL to correspond with the correct font
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
        FONT_DIR="$HOME/.local/share/fonts"
        TEMP_DIR=$(mktemp -d)
        curl -sSLo "$TEMP_DIR"/"${FONT_NAME}".zip "$FONT_URL"
        unzip "$TEMP_DIR"/"${FONT_NAME}".zip -d "$TEMP_DIR"
        mkdir -p "$FONT_DIR"/"$FONT_NAME"
        mv "${TEMP_DIR}"/*.ttf "$FONT_DIR"/"$FONT_NAME"
        fc-cache -fv
        rm -rf "${TEMP_DIR}"
        printf "%b\n" "${GREEN}'$FONT_NAME' installed successfully.${RC}"
}

clone_config_folders() {
    # Ensure the target directory exists
    [ ! -d ~/.config ] && mkdir -p ~/.config
    [ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin

    # get permission back to the user from sudo.. in .config and .local folders
    sudo chown -R "$USER:$USER" ~/.config ~/.local

    # Copy scripts to local bin
    cp -rf "$HOME/.local/share/dwm-wattox/scripts/." "$HOME/.local/bin/"

    # Iterate over all directories in config/*
    for dir in config/*/; do
        # Extract the directory name
        dir_name=$(basename "$dir")

        # Clone the directory to ~/.config/
        if [ -d "$dir" ]; then
            cp -r "$dir" ~/.config/
            printf "%b\n" "${GREEN}Cloned $dir_name to ~/.config/${RC}"
        else
            printf "%b\n" "${RED}Directory $dir_name does not exist, skipping${RC}"
        fi
    done
}

configure_backgrounds() {
    PIC_DIR="$HOME/Pictures"
    BG_DIR="$PIC_DIR/backgrounds"
    SC_DIR="$PIC_DIR/screenshots"

    # Create directories
    mkdir -p "$BG_DIR" "$SC_DIR"

    # Copy backgrounds from repo
    cp -r ~/arch-setup/backgrounds/. "$BG_DIR"

    printf "%b\n" "Backgrounds → $BG_DIR"
    printf "%b\n" "Screenshots → $SC_DIR"
}

checkEnv
checkEscalationTool
installBibata
setupDWM
makeDWM
install_nerd_font
clone_config_folders
configure_backgrounds
installAlacritty
setupAlacrittyConfig
installRofi
setupRofiConfig
installTodol
installLazyvim
