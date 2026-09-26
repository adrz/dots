#!/bin/bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: bash macos/defaults.sh [--preview | --apply | --help]

  --preview  Print the proposed commands (default).
  --apply    Write the preferences for the current macOS user.
  --help     Show this help.

Edit the preferences below before applying. Log out and back in afterward
so that applications reload the settings.
EOF
}

if [ "$#" -gt 1 ]; then
    usage >&2
    exit 1
fi

mode=${1:---preview}
case "$mode" in
    --preview|--apply) ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
esac

if [ "$mode" = "--apply" ]; then
    if [ "$(uname -s)" != "Darwin" ]; then
        echo "Applying these preferences requires macOS." >&2
        exit 1
    fi
    if [ "$EUID" -eq 0 ]; then
        echo "Run this script as your own user, without sudo." >&2
        exit 1
    fi
fi

run() {
    printf '  '
    printf '%q ' "$@"
    printf '\n'
    if [ "$mode" = "--apply" ]; then
        "$@"
    fi
}

# Change this path to choose another destination for future screenshots.
screenshots_dir="$HOME/Pictures/Screenshots"

printf '\nKeyboard: fast repeat with a short initial delay\n'
# These values match the existing setup.
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write NSGlobalDomain InitialKeyRepeat -int 15

printf '\nDock: auto-hide immediately, no animation, no recent apps\n'
run defaults write com.apple.dock autohide -bool true
run defaults write com.apple.dock autohide-delay -float 0
run defaults write com.apple.dock autohide-time-modifier -float 0
run defaults write com.apple.dock show-recents -bool false

printf '\nFinder: visible file details, folders first, search the current folder\n'
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.finder ShowStatusBar -bool true
run defaults write com.apple.finder _FXSortFoldersFirst -bool true
run defaults write com.apple.finder FXDefaultSearchScope -string SCcf

printf '\nScreenshots: PNG files in %s\n' "$screenshots_dir"
run mkdir -p -- "$screenshots_dir"
run defaults write com.apple.screencapture location -string "$screenshots_dir"
run defaults write com.apple.screencapture type -string png

printf '\nTrackpad: tap-to-click enabled; natural scrolling disabled\n'
run defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# This is a shared mouse/trackpad preference, matching the existing setup.
run defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

if [ "$mode" = "--apply" ]; then
    printf '\nPreferences written. Log out and back in to activate the changes.\n'
else
    printf '\nPreview only. Apply with: bash macos/defaults.sh --apply\n'
fi
