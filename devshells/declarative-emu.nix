{ pkgs ? import <nixpkgs> {
  config = {
    android_sdk.accept_license = true;
    allowUnfree = true;
  };
}, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    (callPackage ({ pkgs, ... }:
      pkgs.androidenv.emulateApp rec {
        name = "android-emu-default-api34-x86_64";
        deviceName = name;
        platformVersion = "34";
        abiVersion = "x86_64";
        systemImageType = "default";
        sdkExtraArgs = {
          emulatorVersion = "34.2.11";
        };
        configOptions = {
          "hw.gpu.enabled" = "yes";
          "hw.gpu.mode" = "host";
          "hw.keyboard" = "yes";
        };
        avdHomeDir = "$HOME/.android/avd";
      }) {})
  ];
  shellHook = ''
    # On wayland may not work correctly without this
    export QT_QPA_PLATFORM="xcb"
    # Fix some kind of errors with vulkan
    export LD_LIBRARY_PATH="${pkgs.libglvnd}/lib":$LD_LIBRARY_PATH

    echo "Emulator can be launched by using 'run-test-emulator'"
    echo "If you want provide additional parameters to emulator, use NIX_ANDROID_EMULATOR_FLAGS environment variable"
  '';
}