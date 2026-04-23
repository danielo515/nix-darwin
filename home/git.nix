{
  lib,
  useremail,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  # Git companion apps
  programs.gh = {enable = true;};
  programs.lazygit = {enable = true;};

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {features = "side-by-side";};
  };

  # git config
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = "openpgp";

    settings = {
      user = {
        name = "danielo515";
        email = useremail;
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      alias = {
        # common aliases
        br = "branch";
        co = "checkout";
        st = "status";
        ls = ''
          log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'';
        ll = ''
          log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'';
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";

        # aliases for submodule
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
    };

    ignores = [".DS_Store" "*.swp" "*~" ".vscode" ".idea" ".danielo" "GEMINI.md"];
  };
}
