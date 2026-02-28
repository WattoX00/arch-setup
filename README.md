# Arch Linux Installation Script

A streamlined Arch Linux setup script designed to make installation cleaner, faster, and tailored to my workflow.

Inspired by [ChrisTitusTech](https://github.com/ChrisTitusTech).

## 🚀 Installation

### 1. Run the Bootstrap Script

```bash
bash <(curl -fsSL wattox00.github.io/arch-setup/install.sh)
```

This will install and configure:

A basic user account

Networking

Bootloader

Essential system configuration

At this point, you are free to continue however you like:

Install your preferred desktop environment

Install your own window manager

Keep it minimal and use it as a server

Customize everything manually

The base system is ready — the rest is up to you.

Optional: Install dwm-wattox

If you want to use my custom window manager setup, follow the steps below.

2. Log out and back in

Start a new shell session, then run:

```bash
  bash dwm-wattox.sh
```

3. Run the cleanup script

```bash
bash cleanup.sh
```

⚠️ Note: A full reboot is not required. Logging out and back in is usually enough to apply environment and service changes. Reboot only if you encounter issues.

4. Activate Bash configuration

```bash
source ~/.bashrc
```

Window Manager

This setup installs a custom build of
dwm-wattox

Starting dwm

After logging into a TTY session, start dwm with:

startx
Keybinding

SUPER + / → Open commands menu
(SUPER = Windows key)

Enjoy! 🎉

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
