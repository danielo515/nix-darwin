{ lib
, stdenv
, git
, gh
, writeShellApplication
}:

writeShellApplication {
  name = "repo-cloner";
  runtimeInputs = [ git gh ];
  text = ''
    if [ $# -ne 1 ]; then
      echo "Usage: $0 <target-directory>"
      exit 1
    fi

    TARGET_DIR="$1"
    mkdir -p "$TARGET_DIR"

    if [[ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
      echo "Error: Target directory is not empty: $TARGET_DIR"
      exit 1
    fi

    # Check if user is authenticated with GitHub
    if ! gh auth status &>/dev/null; then
      echo "You need to authenticate with GitHub first."
      echo "Initiating GitHub authentication process..."
      gh auth login
    fi

    # Clone the repository using gh cli
    echo "Cloning repository to $TARGET_DIR..."
    gh repo clone danielo515/nix-darwin "$TARGET_DIR" -- --depth 1
    echo "Repository cloned successfully to $TARGET_DIR"
  '';
}
