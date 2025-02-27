# Custom package overlay
final: prev: {
  # Example of a custom package overlay
  # custom-app = final.callPackage ../pkgs/custom-app { };
  
  # You can also override existing packages
  # some-package = prev.some-package.overrideAttrs (oldAttrs: {
  #   # Your customizations here
  # });
}
