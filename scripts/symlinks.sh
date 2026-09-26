#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_FILE="$SCRIPT_DIR/../symlinks.conf"

# shellcheck source=scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

expand_link_path() {
    local link_path=$1
    local repo_placeholder="\$(pwd)"
    local home_placeholder="\$HOME"
    local braced_home_placeholder="\${HOME}"

    # Expand only the placeholders supported by symlinks.conf, from this repo.
    link_path=${link_path//"$repo_placeholder"/"$DOTFILES_DIR"}
    link_path=${link_path//"$braced_home_placeholder"/"$HOME"}
    link_path=${link_path//"$home_placeholder"/"$HOME"}
    printf '%s\n' "$link_path"
}

is_managed_link() {
    [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]
}

validate_symlinks_config() {
    info "Validating symlinks configuration..."
    local has_error=false
    local source target

    # Read dotfile links from the config file and validate
    while IFS=: read -r source target || [ -n "$source" ]; do
        # Skip empty or invalid lines in the config file
        if [[ -z "$source" || -z "$target" || "$source" =~ ^[[:space:]]*\# ]]; then
            continue
        fi

        source=$(expand_link_path "$source")

        # Check if the source file exists
        if [ ! -e "$source" ]; then
            error "Error: Source file '$source' not found. This would cause an error during linking."
            has_error=true
        else
            success "Valid source: $source"
        fi
    done <"$CONFIG_FILE"

    if [ "$has_error" = true ]; then
        return 1
    else
        success "Symlinks configuration is valid!"
    fi
}

create_symlinks() {
    info "Creating symbolic links..."
    local result=0
    local source target target_dir

    # Read dotfile links from the config file
    while IFS=: read -r source target || [ -n "$source" ]; do

        # Skip empty or invalid lines in the config file
        if [[ -z "$source" || -z "$target" || "$source" =~ ^[[:space:]]*\# ]]; then
            continue
        fi

        source=$(expand_link_path "$source")
        target=$(expand_link_path "$target")

        # Check if the source file exists
        if [ ! -e "$source" ]; then
            error "Error: Source file '$source' not found. Skipping link creation for '$target'."
            result=1
            continue
        fi

        if is_managed_link "$source" "$target"; then
            success "Symbolic link already correct: $target"
        elif [ -e "$target" ] || [ -L "$target" ]; then
            error "Conflict: '$target' already exists and is not the expected symbolic link."
            result=1
        else
            # Extract the directory portion of the target path
            target_dir=$(dirname "$target")

            # Check if the target directory exists, and if not, create it
            if [ ! -d "$target_dir" ]; then
                if ! mkdir -p -- "$target_dir"; then
                    error "Could not create directory: $target_dir"
                    result=1
                    continue
                fi
                info "Created directory: $target_dir"
            fi

            # Create the symbolic link
            if ln -s -- "$source" "$target"; then
                success "Created symbolic link: $target"
            else
                error "Could not create symbolic link: $target"
                result=1
            fi
        fi
    done <"$CONFIG_FILE"
    return "$result"
}

delete_symlinks() {
    info "Deleting symbolic links..."
    local result=0
    local source target

    while IFS=: read -r source target || [ -n "$source" ]; do

        if [[ -z "$source" || -z "$target" || "$source" =~ ^[[:space:]]*\# ]]; then
            continue
        fi

        source=$(expand_link_path "$source")
        target=$(expand_link_path "$target")

        if is_managed_link "$source" "$target"; then
            if rm -- "$target"; then
                success "Deleted: $target"
            else
                error "Could not delete symbolic link: $target"
                result=1
            fi
        elif [ -e "$target" ] || [ -L "$target" ]; then
            warning "Preserving unmanaged target: $target"
        else
            warning "Not found: $target"
        fi
    done <"$CONFIG_FILE"
    return "$result"
}

# Parse arguments
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    if [ "$#" -ne 1 ]; then
        error "Usage: $0 [--create | --delete | --validate-only | --help]"
        exit 1
    fi
    case "$1" in
    "--create")
        create_symlinks
        ;;
    "--delete")
        delete_symlinks
        ;;
    "--validate-only")
        validate_symlinks_config
        ;;
    "--help")
        # Display usage/help message
        echo "Usage: $0 [--create | --delete | --validate-only | --help]"
        ;;
    *)
        # Display an error message for unknown arguments
        error "Error: Unknown argument '$1'"
        error "Usage: $0 [--create | --delete | --validate-only | --help]"
        exit 1
        ;;
    esac
fi
