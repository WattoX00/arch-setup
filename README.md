# My Arch Linux Installation script
Makes it cleaner and faster to my liking.

Inspired by [ChristitusTech](https://github.com/ChrisTitusTech)

## Installation

1. Run the bootstrap script:

   ```bash
   bash <(curl -fsSL https://wattox00.github.io/arch-setup/install.sh)
   ```

2. Log out and log back in (or start a new shell session), then run:

   ```bash
   bash dwm-wattox.sh
   ```

3. Run the cleanup script:

   ```bash
   bash cleanup.sh
   ```

> ⚠️ **Note:** A full reboot is **not** required. Logging out and back in is usually sufficient to apply environment and service changes. Reboot only if you encounter issues.


### Window Manager

This setup installs a custom build of **[dwm-wattox](https://github.com/WattoX00/dwm-wattox)**.

4. Enjoy! 🎉

## Starting `dwm`

After logging into a TTY session, start `dwm` with:

```bash
startx
```

Press **SUPER + /** to open the commands menu  
(**SUPER** = Windows key)

## Packages

<details>
<summary>Click to expand</summary>
🎨 Theming & Appearance

- Bibata Modern Ice – Cursor theme

- feh – Wallpaper management

- nwg-look – GTK theme configuration

- picom – Compositor (transparency, animations)

- polybar – Status bar

🖥 Terminal & Shell Workflow

- Alacritty – Terminal emulator

- Nerd Fonts – Icon and glyph support

- Fastfetch - PC specs

🧠 Editor & Development Tools

- LazyVim – Custom Neovim configuration

🔍 Launchers & Notifications

- Rofi – Application launcher

- Dunst – Notification daemon

📁 File Management

- Thunar – File manager

- tumbler – Thumbnail support

- gvfs – Virtual filesystem support

🔊 Audio & Media Utilities

- PipeWire – Audio server

- pavucontrol – Audio control GUI

- alsa-utils – ALSA utilities

🔐 Session & System Utilities

- mate-polkit – PolicyKit authentication agent

- gnome-keyring – Credential storage

- network-manager-applet – NetworkManager tray applet

🧰 Productivity & Miscellaneous

- flameshot – Screenshot utility

- xclip – Clipboard utility

- xdg-user-dirs – Standard user directories

- flatpak – Flatpak support

- python-pipx – Isolated Python application installs

- Todol – Personal task/todo application

🗂 User Configuration

Custom dotfiles and configuration folders

Custom background setup
</details>

## ❤️ Support

If this project saved you time, taught you something, or made your day a little easier,
you can support its development here:

👉 **[Buy me a coffee via PayPal](https://www.paypal.com/paypalme/wattox)**

Your support helps keep the project:
- Actively maintained
- Continuously improved
- Free and open source

Thanks for being part of the community 🤝

## 📄 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for full details.
