# Arch Linux Installation Script

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Deployment Status](https://img.shields.io/github/deployments/wattox00/arch-setup/github-pages?label=Install%20Script&style=for-the-badge)
[![License](https://img.shields.io/github/license/wattox00/arch-setup?style=for-the-badge)](https://github.com/WattoX00/arch-setup/blob/main/LICENSE)

A streamlined Arch Linux setup script designed to make installation cleaner, faster, and tailored to my workflow.

## 🚀 Installation

## Full setup from fresh booted arch iso
<details>
<summary>Click to expand</summary>

### 1. Run the Bootstrap Script

```bash
bash <(curl -fsSL wattox00.github.io/arch-setup/install.sh)
```

<details>
<summary>This will install and configure:</summary>

- A basic user account

- Networking

- Grub Bootloader

- Essential system configuration

</details>


<details>
<summary>At this point, you are free to continue however you like:</summary>

- Install your preferred desktop environment

- Install your own window manager

- Keep it minimal and use it as a server

- Customize everything manually

- The base system is ready - the rest is up to you.

</details>

#### Optional: Install dwm-wattox

If you want to use my custom window manager setup, follow the steps below.

### 2. Log out and back in

Start a new shell session, then run:

```bash
  cd ~
  bash arch-setup/dwm-wattox.sh
```

### 3. Run the cleanup script

```bash
bash cleanup.sh
```

⚠️ Note: A full reboot is not required. Logging out and back in is usually enough to apply environment and service changes. Reboot only if you encounter issues.

</details>

## DWM-wattox only
<details>
<summary>Click to expand</summary>

### Pre-setup requirements

You should have:

- A basic user account logged in (not root)
- Network connection
- `git`
- A package manager (e.g pacman)
- A basic TTY

Then continue with the steps below.

### 1. Clone the Git repository

```bash
git clone https://github.com/wattox00/arch-setup.git
cd arch-setup
chmod +x dwm-wattox.sh
bash dwm-wattox.sh
```

### 2. Run cleanup

The dwm-wattox.sh script will copy a cleanup.sh file into your home folder.

Running it will:

- Remove unnecessary folders and files used during installation and automation

- Remove the cleanup.sh file itself

- Copy my Bash configuration files

- Ask for sound setup

- Run pipx ensurepath

- Reload your Bash configuration

```bash
cd ~
bash cleanup.sh
```

</details>

<details>
<summary>Starting dwm</summary>


After logging into a TTY session, start dwm with:

```bash
startx
```

#### Keybinding

SUPER + / -> Open commands menu
(SUPER = Windows key)

Enjoy! 🎉

For more check out the original dwm-wattox page: [HERE](https://github.com/WattoX00/dwm-wattox)

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

Inspired by [ChrisTitusTech](https://github.com/ChrisTitusTech).
This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for full details.
