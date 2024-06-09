{
  pkgs ? (import <nixpkgs> {
    config = {
      android_sdk.accept_license = true;
      allowUnfree = true;
    };
  }),
  android-pkgs ? pkgs.callPackage <android-nixpkgs> {
    channel = "stable";
  },
  ...
}:
let
  android-sdk = android-pkgs.sdk (sdkPkgs: with sdkPkgs; [
    cmdline-tools-latest
    build-tools-34-0-0
    platform-tools
    platforms-android-34
    emulator
    system-images-android-34-default-x86-64
  ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Read ./shell-with-sdk for more information about android-studio and custom android-sdk
    # android-studio
    android-sdk
  ];

  shellHook = ''
    export ANDROID_HOME="${android-sdk}/share/android-sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export ANDROID_USER_HOME="$HOME/.android"
    export ANDROID_AVD_HOME="$HOME/.android/avd"

    # On wayland may not work correctly without this
    export QT_QPA_PLATFORM="xcb"
    # Fix some kind of errors with vulkan
    export LD_LIBRARY_PATH="${pkgs.libglvnd}/lib":$LD_LIBRARY_PATH
  '';
}