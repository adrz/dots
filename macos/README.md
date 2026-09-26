# macOS preferences

`defaults.sh` records selected preferences for the current user. Run it explicitly;
`make install` does not apply macOS preferences.

| Area | Proposed preference | Basis |
| --- | --- | --- |
| Keyboard | Fast repeat (`KeyRepeat=2`), short delay (`InitialKeyRepeat=15`) | Existing setup |
| Dock | Auto-hide, no animation, hide recent applications | Existing setup |
| Dock | Remove the delay before showing the Dock | Addition |
| Finder | Show extensions, path bar, and status bar | Existing setup |
| Finder | Keep folders first when sorting by name; search the current folder | Addition |
| Screenshots | Save future screenshots as PNG in `~/Pictures/Screenshots` | Addition |
| Trackpad | Enable tap-to-click for built-in and Bluetooth trackpads | Existing setup |
| Scrolling | Disable natural scrolling for mouse and trackpad | Existing setup |

The existing values were read from this Mac on 2026-09-26. Edit the commands in
`defaults.sh` to change the proposed values or remove individual preferences.

Preview the commands:

```sh
make macos
# Equivalent: bash macos/defaults.sh --preview
```

Apply the preferences:

```sh
make macos-apply
# Equivalent: bash macos/defaults.sh --apply
```

Running the script without arguments also previews the commands. Apply as your
normal user. The script creates the screenshot directory and writes only the
listed preferences. Existing screenshots stay in their current locations.

Log out and back in after applying so that applications reload the preferences.
You can adjust the settings through System Settings, Finder settings, and the
Screenshot app afterward; applying the script again restores the versioned values.

Apple documents the [defaults preference tool](https://support.apple.com/guide/terminal/edit-property-lists-apda49a1bb2-577e-4721-8f25-ffc0836f6997/mac),
[keyboard repeat settings](https://support.apple.com/guide/mac-help/set-how-quickly-a-key-repeats-mchl0311bdb4/mac),
[trackpad settings](https://support.apple.com/guide/mac-help/change-trackpad-settings-mchlp1226/mac),
and [screenshot destinations](https://support.apple.com/en-us/102646).
