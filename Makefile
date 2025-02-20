# This is here just in case I have problems with the setup and just does not work.
# Then, just use the makefile instead
# please change 'hostname' to your hostname
deploy:
	nix build .#darwinConfigurations.Danielos-MacBook-Pro.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#Danielos-MacBook-Pro