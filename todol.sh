#!/bin/sh -e

# todol is my python todo list app (i use it every day..)
installTodol() {
  export PATH="$HOME/.local/bin:$PATH"
  pipx install todol
  pipx ensurepath
}

