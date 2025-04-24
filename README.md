# Dotfiles

A personal collection of configuration files for various tools including:
- Neovim (with LazyVim)
- Wezterm
- i3 window manager
- ZSH with custom configuration
- Development tools and utilities

## 📋 Contents

- [Installation](#installation)
- [Features](#features)
- [Components](#components)
- [Customization](#customization)
- [Keybindings](#keybindings)
- [Screenshots](#screenshots)
- [License](#license)

## 🚀 Installation

Clone this repository to your desired location:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Quick Setup

Use the Makefile to automatically set up all configurations:

```bash
make install
```

This will:

1. Check and install prerequisites (Xcode CLI tools and Homebrew on macOS)
2. Create symbolic links to configuration files

### Manual Installation

You can also install components individually:

```bash
# Install prerequisites only
make prereq

# Create symbolic links only
make symlinks

# Install Homebrew packages
make brew-install
```

### Cleaning Up

To remove all symbolic links:

```bash
make clean
```

## ✨ Features

- **ZSH Configuration**: Custom prompt, aliases, and plugins
- **Neovim Setup**: Full-featured development environment using LazyVim
- **WezTerm**: GPU-accelerated terminal emulator with custom keybindings
- **i3 Config**: Tiling window manager setup (for Linux)
- **Development Tools**: Python, Git, and other utilities
## 🧩 Components

### Neovim

A modern text editor configuration using LazyVim with:

- LSP support for code completion and diagnostics
- Tree-sitter for improved syntax highlighting
- Fuzzy finding and navigation
- Git integration
- Python development tools

### WezTerm

A GPU-accelerated terminal emulator with:

- Custom color scheme
- Special key mappings for improved productivity
- Modern look and feel

### ZSH

Shell configuration including:

- Powerlevel10k prompt
- Auto-suggestions and syntax highlighting
- Custom aliases and functions
- Git integration
- Tool completions

### i3 (Linux only)

Window manager configuration with:

- Custom keybindings
- Status bar configuration
- Window appearance settings

## 🛠️ Customization

### Adding New Symlinks

Edit the `symlinks.conf` file to add new configuration files:

```bash
$(pwd)/path/to/source:$HOME/path/to/target
```

Then run `make symlinks` to create the new links.

### Homebrew Packages

Add new packages to the `Brewfile` and run:

```bash
make brew-install
```

## ⌨️ Keybindings

### WezTerm

- `Ctrl+F`: Toggle fullscreen
- `Alt+N`: Send tilde (~) character
- `Alt+(`: Send { character
- `Alt+)`: Send } character
- `Alt+Shift+(`: Send [ character
- `Alt+Shift+)`: Send ] character
- `Alt+Shift+L`: Send | character
- `Alt+Shift+:`: Send \ character

### Neovim

See LazyVim documentation for default keybindings.
