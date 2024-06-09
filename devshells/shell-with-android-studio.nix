{ pkgs ? import <nixpkgs> {
  config.allowUnfree = true;
}, ... }:
pkgs.mkShell {
  packages = with pkgs; [
    android-studio
  ];
  shellHook = ''
    export ANDROID_USER_HOME=$HOME/.android
    export ANDROID_AVD_HOME=$HOME/.android/avd
  '';
}