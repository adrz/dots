.PHONY: all install symlinks clean prereq xcode homebrew check-xcode check-brew help brew-install

# Default target
all: help

# Define shell to use
SHELL := /bin/bash

# Get the directory of the Makefile
DOTFILES_DIR := $(shell pwd)

# Install everything
install: prereq symlinks
	@echo "Installation complete!"

# Create symbolic links
symlinks:
	@echo "Creating symbolic links..."
	@bash $(DOTFILES_DIR)/scripts/symlinks.sh --create

# Clean up symbolic links
clean:
	@echo "Cleaning up symbolic links..."
	@bash $(DOTFILES_DIR)/scripts/symlinks.sh --delete

# Interactive prerequisites installation
prereq: check-xcode check-brew

# Check and install Xcode CLI tools if needed
check-xcode:
	@if ! xcode-select -p >/dev/null 2>&1; then \
		read -p "Xcode CLI tools not found. Would you like to install them? [y/N] " answer; \
		if [[ "$$answer" =~ ^[Yy]$$ ]]; then \
			echo "Installing Xcode CLI tools..."; \
			bash $(DOTFILES_DIR)/scripts/prerequisites.sh install_xcode; \
		else \
			echo "Skipping Xcode CLI tools installation."; \
		fi \
	else \
		echo "Xcode CLI tools already installed."; \
	fi

# Check and install Homebrew if needed
check-brew:
	@if ! hash brew 2>/dev/null; then \
		read -p "Homebrew not found. Would you like to install it? [y/N] " answer; \
		if [[ "$$answer" =~ ^[Yy]$$ ]]; then \
			echo "Installing Homebrew..."; \
			bash $(DOTFILES_DIR)/scripts/prerequisites.sh install_homebrew; \
		else \
			echo "Skipping Homebrew installation."; \
		fi \
	else \
		echo "Homebrew already installed."; \
	fi

# Install all packages from Brewfile
brew-install:
	@if ! hash brew 2>/dev/null; then \
		echo "Homebrew is not installed. Please run 'make homebrew' first."; \
		exit 1; \
	fi; \
	echo "Installing packages from Brewfile..."; \
	brew bundle --file=$(DOTFILES_DIR)/Brewfile || { \
		echo "Error installing packages from Brewfile. Please check for issues."; \
		exit 1; \
	}; \
	echo "All packages from Brewfile installed successfully."

# Install Xcode CLI tools directly
xcode:
	@bash $(DOTFILES_DIR)/scripts/prerequisites.sh install_xcode

# Install Homebrew directly
homebrew:
	@bash $(DOTFILES_DIR)/scripts/prerequisites.sh install_homebrew

# Display help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install      Install prerequisites (if needed) and create symlinks"
	@echo "  symlinks     Only create symbolic links"
	@echo "  clean        Remove all symbolic links"
	@echo "  prereq       Check and prompt to install prerequisites (Xcode CLI & Homebrew)"
	@echo "  brew-install Install all packages from Brewfile"
	@echo "  xcode        Install Xcode CLI tools (no prompt)"
	@echo "  homebrew     Install Homebrew (no prompt)"
	@echo "  help         Display this help message"
