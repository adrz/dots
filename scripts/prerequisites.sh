#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

CHECK_ONLY=false

# Parse command line options
for arg in "$@"; do
  case $arg in
    --check-only)
      CHECK_ONLY=true
      shift
      ;;
  esac
done

install_xcode() {
    info "Installing Apple's CLI tools (prerequisites for Git and Homebrew)..."
    if xcode-select -p >/dev/null; then
        warning "xcode is already installed"
    else
        if [ "$CHECK_ONLY" = true ]; then
            info "Would install xcode CLI tools (skipped in check-only mode)"
        else
            xcode-select --install
            sudo xcodebuild -license accept
        fi
    fi
}

install_homebrew() {
    info "Installing Homebrew..."
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if hash brew &>/dev/null; then
        warning "Homebrew already installed"
    else
        if [ "$CHECK_ONLY" = true ]; then
            info "Would install Homebrew (skipped in check-only mode)"
        else
            sudo --validate
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
    fi
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_xcode
    install_homebrew
fi
