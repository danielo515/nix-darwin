{ git, gh, gum, writeShellApplication }:

writeShellApplication {
  name = "repo-cloner";
  runtimeInputs = [ git gh gum ];
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

    # Show welcome message
    gum style \
      --border normal \
      --margin "1" \
      --padding "1" \
      --border-foreground 212 \
      "Welcome to $(gum style --foreground 212 --bold 'repo-cloner')!" \
      "This utility will clone the danielo515/nix-darwin repository and help you set it up."

    # Check arguments
    if [ $# -ne 1 ]; then
      error "Usage: $0 <target-directory>"
    fi

    TARGET_DIR="$1"
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
      gh repo clone danielo515/nix-darwin "$TARGET_DIR" -- --depth 1
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
