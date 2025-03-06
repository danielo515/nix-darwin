{ git, gh, gum, writeShellApplication }:

# writeShellApplication provides the following environment variables by default:
# - All the standard Nix build environment variables (NIX_STORE, NIX_BUILD_TOP, etc.)
# - PATH is initially set to /path-not-set but will include all runtimeInputs
# - HOME is set to /homeless-shelter by default
# - The name of the script is available via the command name ($0)
# 
# Additional environment variables can be set via the runtimeEnv attribute
writeShellApplication {
  name = "repo-cloner";
  runtimeInputs = [ git gh gum ];
  runtimeEnv = {
    REPO_OWNER = "danielo515";
    REPO_NAME = "nix-darwin";
    REPO_FULL = "danielo515/nix-darwin";
  };
  text = ''
    # Function to display styled section headers
    section() {
      gum style --foreground 212 --bold --underline "$1"
    }

    # Function to display styled info messages
    info() {
      gum style --foreground 39 "→ $1"
    }

    # Function to display styled success messages
    success() {
      gum style --foreground 76 "✓ $1"
    }

    # Function to display styled error messages
    error() {
      gum style --foreground 196 "✗ $1"
      exit 1
    }

    # Check arguments
    if [ $# -ne 1 ]; then
      error "Usage: $(basename "$0") <target-directory>"
    fi

    TARGET_DIR="$1"

    # Show welcome message
    gum style \
      --border normal \
      --margin "1" \
      --padding "1" \
      --border-foreground 212 \
      "Welcome to $(gum style --foreground 212 --bold "$(basename "$0")")!" \
      "This utility will clone the $REPO_FULL repository and help you set it up."

    mkdir -p "$TARGET_DIR"

    if [[ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
      error "Target directory is not empty: $TARGET_DIR"
    fi

    section "GitHub Authentication"

    # Check if user is authenticated with GitHub
    if ! gh auth status &>/dev/null; then
      info "You need to authenticate with GitHub first."
      if gum confirm "Would you like to authenticate with GitHub now?"; then
        info "Initiating GitHub authentication process..."
        gh auth login
      else
        error "GitHub authentication is required to continue."
      fi
    else
      success "Already authenticated with GitHub."
    fi

    section "Cloning Repository"

    # Clone the repository using gh cli with a spinner
    info "Cloning repository to $TARGET_DIR..."
    gum spin --spinner dot --title "Cloning repository..." -- \
      gh repo clone "$REPO_FULL" "$TARGET_DIR" -- --depth 1
    success "Repository cloned successfully to $TARGET_DIR"
    
    # Check if running on macOS
    if [[ "$(uname)" == "Darwin" ]]; then
      section "macOS Configuration"
      info "Detected macOS system."
      
      if gum confirm "Would you like to build and switch to this configuration?"; then
        info "Building and switching to the new configuration..."
        cd "$TARGET_DIR"
        
        # Check if nix-darwin is already installed
        if command -v darwin-rebuild &>/dev/null; then
          success "Using existing nix-darwin installation."
          
          # Show spinner while building
          gum spin --spinner dot --title "Building and switching configuration..." -- \
            darwin-rebuild switch --flake ".#"
          
          success "Configuration switched successfully!"
        else
          info "Installing nix-darwin..."
          
          # Build and switch using the flake with progress indicators
          info "Building initial system..."
          gum spin --spinner dot --title "Building initial system..." -- \
            nix build --no-link "$TARGET_DIR#darwinConfigurations.$(hostname -s).system"
          
          info "Switching to new configuration..."
          gum spin --spinner dot --title "Switching to new configuration..." -- \
            "$TARGET_DIR/result/sw/bin/darwin-rebuild" switch --flake "$TARGET_DIR#"
          
          success "Configuration switched successfully!"
        fi
        
        # Show final success message
        gum style \
          --border normal \
          --margin "1" \
          --padding "1" \
          --border-foreground 76 \
          "$(gum style --foreground 76 --bold "Success!")" \
          "Your nix-darwin configuration has been set up and activated."
      else
        info "Skipping configuration switch."
        gum style \
          --foreground 39 \
          "You can manually switch to this configuration later with:" \
          "  cd $TARGET_DIR" \
          "  darwin-rebuild switch --flake .#"
      fi
    else
      info "Not running on macOS, skipping nix-darwin switch."
    fi
  '';
}
