#!/bin/sh -e

# todol is my python todo list app
installTodol() {
  export PATH="$HOME/.local/bin:$PATH"
  pipx install todol
}

# lysn is my music player
installLysn() {
  export PATH="$HOME/.local/bin:$PATH"
  pipx install lysn
}
