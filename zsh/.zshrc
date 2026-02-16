#===============================================================================
# ~/.zshrc - ZSH configuration file
#===============================================================================

#-------------------------------------------------------------------------------
# Powerlevel10k Instant Prompt
#-------------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k theme
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Load Powerlevel10k configuration if exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
setopt PROMPT_SUBST


#-------------------------------------------------------------------------------
# Oh-My-Zsh Configuration
#-------------------------------------------------------------------------------
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
# Load selected Oh-My-Zsh plugins
plugins=(
    git         # Git integration and aliases
    colorize    # Syntax highlighting for cat command
    docker      # Docker commands and container completion
    command-not-found  # Suggests package containing missing command
    autojump    # Smart directory jumping
    extract     # Extract various archive formats
    gitignore   # Create .gitignore files easily
)

source $ZSH/oh-my-zsh.sh

#-------------------------------------------------------------------------------
# Environment Variables
#-------------------------------------------------------------------------------
# Default editor
export EDITOR=nvim
source <(fzf --zsh)

alias f="fzf"
alias h="fzf"
# Path configuration
#export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/opt/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$GOPATH/bin
#export PATH=$PATH:$HOME/.cargo/env
export PATH="$PATH:/Users/dude/.local/bin"  # Added by pipx
# export PATH=$PATH:"~/dev/zig/" # zig 0.16
# for psql
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# GPG terminal setting
export GPG_TTY=$(tty)

#-------------------------------------------------------------------------------
# Key Bindings
#-------------------------------------------------------------------------------
# Up/down for history search (starts with current input)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

#-------------------------------------------------------------------------------
# Theme & Visual Enhancements
#-------------------------------------------------------------------------------
# Load zsh plugins for autosuggestions and syntax highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#-------------------------------------------------------------------------------
# Aliases & Custom Functions
#-------------------------------------------------------------------------------
# Python environment management

alias mpva='~/.venv/bin/python $HOME/.config/mpv/mpv_annotator/annotation_navigator.py'

alias sl="source ~/.venv/bin/activate"

# Use neovim instead of vim
alias vim="nvim"

# Use lsd (modern ls) with defaults
alias ls="lsd -lh"
alias lsm="lsd -lhtr"

# Zoxide (better directory navigation)
eval "$(zoxide init zsh)"
alias cd="z"

# git checkout
alias gc="git checkout"

# ssh to machine
alias ssh_pelleport="ssh -J moka@moka-server adrien@192.168.123.141"
alias ssh_pelleport_louis="ssh -J moka@moka-server moka@192.168.123.202"
alias ssh_paul="ssh -J moka@moka-server paul@192.168.123.77"
alias ssh_ccl="ssh -J moka@moka-server moka@192.168.123.9"
alias ssh_ccl3="ssh -J moka@moka-server moka@192.168.123.153"
alias ssh_radxa="ssh -J moka@moka-server moka@192.168.123.53"
alias proxy_mokaserver="ssh -D 1080 -N moka@moka-server"
# jump forward for pelleport
# Function for SSH port forwarding via a jump host
# Usage: jf <local_port> <remote_port>
jf() {
    # Check if both arguments are provided
    if [ "$#" -ne 2 ]; then
        echo "Error: You must specify the local and remote port."
        echo "Usage: jf <local_port> <remote_port>"
        return 1
    fi

    local local_port=$1
    local remote_port=$2

    echo "Forwarding local port ${local_port} to 192.168.123.141:${remote_port} via moka-server...\nLocal url: http://localhost:${local_port}"
    ssh -Nn -L "${local_port}:localhost:${remote_port}" -J moka@moka-server adrien@192.168.123.141
}


# Shell helpers
eval $(thefuck --alias)  # Corrects your previous console command

#-------------------------------------------------------------------------------
# Tool Completions & Integrations
#-------------------------------------------------------------------------------
# Rust
. "$HOME/.cargo/env"

# Python package management
eval "$(uv generate-shell-completion zsh)"
# eval "$(uvx --generate-shell-completion zsh)"


#-------------------------------------------------------------------------------
# GitHub Copilot CLI Functions
#-------------------------------------------------------------------------------
# GitHub Copilot Command Suggester
ghcs() {
	FUNCNAME="$funcstack[1]"
	TARGET="shell"
	local GH_DEBUG="$GH_DEBUG"
	local GH_HOST="$GH_HOST"

	read -r -d '' __USAGE <<-EOF
	Wrapper around \`gh copilot suggest\` to suggest a command based on a natural language description of the desired output effort.
	Supports executing suggested commands if applicable.

	USAGE
	  $FUNCNAME [flags] <prompt>

	FLAGS
	  -d, --debug           Enable debugging
	  -h, --help            Display help usage
	      --hostname        The GitHub host to use for authentication
	  -t, --target target   Target for suggestion; must be shell, gh, git
	                        default: "$TARGET"

	EXAMPLES

	- Guided experience
	  $ $FUNCNAME

	- Git use cases
	  $ $FUNCNAME -t git "Undo the most recent local commits"
	  $ $FUNCNAME -t git "Clean up local branches"
	  $ $FUNCNAME -t git "Setup LFS for images"

	- Working with the GitHub CLI in the terminal
	  $ $FUNCNAME -t gh "Create pull request"
	  $ $FUNCNAME -t gh "List pull requests waiting for my review"
	  $ $FUNCNAME -t gh "Summarize work I have done in issues and pull requests for promotion"

	- General use cases
	  $ $FUNCNAME "Kill processes holding onto deleted files"
	  $ $FUNCNAME "Test whether there are SSL/TLS issues with github.com"
	  $ $FUNCNAME "Convert SVG to PNG and resize"
	  $ $FUNCNAME "Convert MOV to animated PNG"
	EOF

	local OPT OPTARG OPTIND
	while getopts "dht:-:" OPT; do
		if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
			OPT="${OPTARG%%=*}"       # extract long option name
			OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
			OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
		fi

		case "$OPT" in
			debug | d)
				GH_DEBUG=api
				;;

			help | h)
				echo "$__USAGE"
				return 0
				;;

			hostname)
				GH_HOST="$OPTARG"
				;;

			target | t)
				TARGET="$OPTARG"
				;;
		esac
	done

	# shift so that $@, $1, etc. refer to the non-option arguments
	shift "$((OPTIND-1))"

	TMPFILE="$(mktemp -t gh-copilotXXXXXX)"
	trap 'rm -f "$TMPFILE"' EXIT
	if GH_DEBUG="$GH_DEBUG" GH_HOST="$GH_HOST" gh copilot suggest -t "$TARGET" "$@" --shell-out "$TMPFILE"; then
		if [ -s "$TMPFILE" ]; then
			FIXED_CMD="$(cat $TMPFILE)"
			print -s "$FIXED_CMD"
			echo
			eval "$FIXED_CMD"
		fi
	else
		return 1
	fi
}

# GitHub Copilot Command Explainer
ghce() {
	FUNCNAME="$funcstack[1]"
	local GH_DEBUG="$GH_DEBUG"
	local GH_HOST="$GH_HOST"

	read -r -d '' __USAGE <<-EOF
	Wrapper around \`gh copilot explain\` to explain a given input command in natural language.

	USAGE
	  $FUNCNAME [flags] <command>

	FLAGS
	  -d, --debug      Enable debugging
	  -h, --help       Display help usage
	      --hostname   The GitHub host to use for authentication

	EXAMPLES

	# View disk usage, sorted by size
	$ $FUNCNAME 'du -sh | sort -h'

	# View git repository history as text graphical representation
	$ $FUNCNAME 'git log --oneline --graph --decorate --all'

	# Remove binary objects larger than 50 megabytes from git history
	$ $FUNCNAME 'bfg --strip-blobs-bigger-than 50M'
	EOF

	local OPT OPTARG OPTIND
	while getopts "dh-:" OPT; do
		if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
			OPT="${OPTARG%%=*}"       # extract long option name
			OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
			OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
		fi

		case "$OPT" in
			debug | d)
				GH_DEBUG=api
				;;

			help | h)
				echo "$__USAGE"
				return 0
				;;

			hostname)
				GH_HOST="$OPTARG"
				;;
		esac
	done

	# shift so that $@, $1, etc. refer to the non-option arguments
	shift "$((OPTIND-1))"

	GH_DEBUG="$GH_DEBUG" GH_HOST="$GH_HOST" gh copilot explain "$@"
}

#-------------------------------------------------------------------------------
# End of .zshrc
#-------------------------------------------------------------------------------

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dude/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dude/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/dude/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dude/google-cloud-sdk/completion.zsh.inc'; fi

    # Fix completions for uv run.
_uv_run_mod() {
	if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
		_arguments '*:filename:_files'
	else
		_uv "$@"
	fi
}
compdef _uv_run_mod uv


# Function to automatically activate/deactivate Python .venv
auto_venv_switch() {
  # If a .venv/bin/activate file exists and it's not the currently active venv
  if [[ -f ".venv/bin/activate" && "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
    # Uncomment the line below for a notification when activating
    # echo -e "\n🐍 Activating virtual environment..."
    source ".venv/bin/activate"
  # If a venv is active, but we've moved out of its project directory
  elif [[ -n "$VIRTUAL_ENV" && ! "$PWD" -ef "$(dirname "$VIRTUAL_ENV")" && ! "$PWD" =~ ^"$(dirname "$VIRTUAL_ENV")"/ ]]; then
    # Uncomment the line below for a notification when deactivating
    # echo -e "\n🐍 Deactivating virtual environment."
    deactivate
  fi
}

# Use add-zsh-hook to add the function to chpwd, which runs on dir change
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_venv_switch

# Run the function once at shell startup
auto_venv_switch


[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


source /Users/dude/.config/broot/launcher/bash/br
# zerobrew
export ZEROBREW_DIR=/Users/dude/.zerobrew
export ZEROBREW_BIN=/Users/dude/.local/bin
_zb_path_append() {
    local argpath="$1"
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac;
}
_zb_path_append /opt/zerobrew/prefix/bin





. /Users/dude/export-esp.sh

# opencode
export PATH=/Users/dude/.opencode/bin:$PATH
