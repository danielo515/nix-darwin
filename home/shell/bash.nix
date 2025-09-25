# Bash configuration
_: {
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = ["erasedups" "ignoredups" "ignorespace"];

    historyFileSize = 10000;
    historySize = 10000;

    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];

    initExtra = ''
      # Set prompt
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

      # Add additional paths
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };
}
