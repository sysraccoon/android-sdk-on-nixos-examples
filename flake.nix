{
  description = "Different ways to setup Android SDK";

  inputs = {
    # This flake probably should work on stable branch, but I don't test
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, android-nixpkgs, ... }:
    let
      # Note: android-studio available only on x86_64-linux
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forSingleSystem = system: f:
          f rec {
            pkgs = import nixpkgs { 
              inherit system;
              config = {
                # android-studio and some parts of SDK's distributed as unfree
                allowUnfree = true;
                # Accept android-sdk license here
                android_sdk.accept_license = true;
              };
            };
            android-pkgs = pkgs.callPackage android-nixpkgs {};
          };
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: forSingleSystem system f);
    in {
      # Use nix develop to run any of this. As example:
      # nix develop ".#shell-with-sdk" -c "$SHELL" 
      devShells = forAllSystems (args: {
        android-nixpkgs = import ./devshells/android-nixpkgs.nix args;
        declarative-emu = import ./devshells/declarative-emu.nix args;
        fhs-with-dependencies = import ./devshells/fhs-with-dependencies.nix args;
        shell-with-android-studio = import ./devshells/shell-with-android-studio.nix args;
        shell-with-sdk = import ./devshells/shell-with-sdk.nix args;
      });

      # It can really work as nixos modules, but I recommend just copy paste content to your configuration.nix file
      nixosModules = forSingleSystem "x86_64-linux" (args: {
        nix-ld = import ./nixos-modules/nix-ld.nix args;
        vulkan-fix = import ./nixos-modules/vulkan-fix.nix args;
      });

      # No need use it as actual module, just copy paste content to your home-manager configuration
      homeManagerModules = forAllSystems (args: {
        xwayland = import ./hm-modules/xwayland.nix args;
      });
    };
}
