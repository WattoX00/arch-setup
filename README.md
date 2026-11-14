# Arch Linux Installation Script

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Deployment Status](https://img.shields.io/github/deployments/wattox00/arch-setup/github-pages?label=Install%20Script&style=for-the-badge)
[![License](https://img.shields.io/github/license/wattox00/arch-setup?style=for-the-badge)](https://github.com/WattoX00/arch-setup/blob/main/LICENSE)

A streamlined Arch Linux setup script designed to make installation cleaner, faster, and tailored to my workflow.

---

## 🚀 Installation

### Full Setup – Fresh Arch Linux ISO

Boot into the Arch Linux ISO and run the bootstrap script:

```bash
bash <(curl -fsSL https://wattox00.github.io/arch-setup/install.sh)
```

The script will install and configure:

- A basic user account
- Networking
- GRUB bootloader
- Essential system configuration

Once the base system is ready, you're free to continue however you like:

- Install your preferred desktop environment
- Install your own window manager
- Keep it minimal and use it as a server
- Customize everything manually

The base system is ready – the rest is up to you.

---

### Optional: Install dwm-wattox

Want my custom window manager setup?

Repository: https://github.com/WattoX00/dwm-wattox

After the bootstrap installation:

**1. Log out and back in**

Start a new shell session, then run:

```bash
cd ~
bash arch-setup/dwm-wattox.sh
```

**2. Run the cleanup script**

```bash
bash cleanup.sh
```

> ⚠️ **Note:** A full reboot is not required. Logging out and back in is usually enough to apply environment and service changes. Reboot only if you encounter issues.

---

## 🪟 dwm-wattox Only

Already have an Arch Linux installation and just want the window manager?

### Requirements

- A basic user account (not root)
- Network connection
- `git`
- A package manager (e.g. `pacman`)
- A basic TTY

### 1. Clone the repository

```bash
git clone https://github.com/wattox00/arch-setup.git
cd arch-setup
chmod +x dwm-wattox.sh
bash dwm-wattox.sh
```

### 2. Run cleanup

The `dwm-wattox.sh` script copies a `cleanup.sh` file into your home directory.

The cleanup script will:

- Remove unnecessary folders and files used during installation and automation
- Remove itself after execution
- Copy my Bash configuration files
- Ask for sound setup
- Run `pipx ensurepath`
- Reload your Bash configuration

Run it with:

```bash
cd ~
bash cleanup.sh
```

### 3. Start dwm

After logging into a TTY session, start dwm with:

```bash
startx
```

### Keybinding

| Keys | Action |
| --- | --- |
| `SUPER` + `/` | Open commands menu |

`SUPER` = Windows key

Enjoy! 🎉

For more information, visit the original [dwm-wattox repository](https://github.com/WattoX00/dwm-wattox).

---

## ❤️ Support

If this project saved you time, taught you something, or made your day a little easier, you can support its development here:

👉 [Buy me a coffee via PayPal](https://www.paypal.com/paypalme/wattox)

Your support helps keep the project:

- Actively maintained
- Continuously improved
- Free and open source

Thanks for being part of the community! 🤝

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/WattoX00/arch-setup/blob/main/LICENSE) file for full details.

Inspired by [ChrisTitusTech](https://github.com/ChrisTitusTech).
