# My Arch Linux Installation script
Makes it cleaner and faster to my liking.

Inspired by [ChristitusTech](https://github.com/ChrisTitusTech)

## Installation

1. Run the bootstrap script:

   ```bash
   bash <(curl -fsSL wattox00.github.io/arch-setup/install.sh)
   ```

After that you will have a basic user, internet and boot setup, you can go ahead and install a desktop manager (like kde plasma), or a windowmanager like dwm-wattox:

2. Log out and log back in (or start a new shell session), then run:

   ```bash
   bash dwm-wattox.sh
   ```

3. Run the cleanup script:

   ```bash
   bash cleanup.sh
   ```

> ⚠️ **Note:** A full reboot is **not** required. Logging out and back in is usually sufficient to apply environment and service changes. Reboot only if you encounter issues.

4. Activate bash config:

```bash
source .bashrc
```
```
```

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
