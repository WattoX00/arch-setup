#!/bin/sh -e

installBibata() {
    mkdir -p ~/.icons
    curl -L \
      https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz \
      | tar -xJ -C ~/.icons
}
