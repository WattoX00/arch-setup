#!/bin/sh -e

installLazyvim() {
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
}
