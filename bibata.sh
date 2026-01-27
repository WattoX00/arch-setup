#!/bin/sh -e

installBibata() {
    git clone https://aur.archlinux.org/bibata-cursor-theme-bin.git
    cd bibata-cursor-theme-bin
    makepkg -si
}