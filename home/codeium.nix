{
  config,
  lib,
  dotfilesPath,
  ...
}: let
  codeiumDir = "${config.home.homeDirectory}/.codeium";
  codeiumExists = builtins.pathExists codeiumDir;
in {
  home.file = lib.mkIf codeiumExists {
    ".codeium/windsurf/memories/global_rules.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/global_rules.md";
  };
}
