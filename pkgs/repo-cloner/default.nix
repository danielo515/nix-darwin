{ lib
, stdenv
, git
, writeShellApplication
}:

writeShellApplication {
  name = "repo-cloner";
  runtimeInputs = [ git ];
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

    git clone --depth 1 "https://github.com/danielo515/nix-darwin.git" "$TARGET_DIR"
    echo "Repository cloned successfully to $TARGET_DIR"
  '';
}
