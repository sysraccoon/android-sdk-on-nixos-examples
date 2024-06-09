{pkgs ? import <nixpkgs> {
  config = {
    android_sdk.accept_license = true;
    allowUnfree = true;
  };
}, ...}: let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    toolsVersion = "26.1.1";
    platformToolsVersion = "35.0.1";
    buildToolsVersions = [ "34.0.0" ];

    includeEmulator = true;
    emulatorVersion = "34.2.11";

    includeSystemImages = true;
    # This generate cartesian product of defined image options
    # For example below
    # system-images;android-27;default;x86_64
    # system-images;android-34;default;x86_64
    platformVersions = ["27" "34"];
    abiVersions = ["x86_64"];
    systemImageTypes = ["default"];

    includeSources = false; 
    includeNDK = false;
    useGoogleAPIs = false;

    # Uncomment if you use something, that require extra license
    extraLicenses = [
      # "android-sdk-preview-license"
      # "android-googletv-license"
      # "android-sdk-arm-dbt-license"
      # "google-gdk-license"
      # "intel-android-extra-license"
      # "intel-android-sysimage-license"
      # "mips-android-sysimage-license"
    ];
  };
  androidSdk = androidComposition.androidsdk;
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # You could use Android Studio with this devshell
    # But them reuse your ~/.config/Google/AndroidStudio* configuration
    #
    # If you already setup some SDK and want instead use {androidSdk} defined here,
    # change path in Android Studio settings. If you don't do that, you can get weird
    # errors inside Virtual Device Manager, caused by differences between two SDK.
    #
    # If your configuration folder is empty, Android Studio will find
    # SDK by your ANDROID_HOME path. And detected that it accessible RO
    # This trigger error "The Android SDK location cannot be at the filesystem root"
    # And don't allow you use Virtual Device Manager.
    # Do not run them as root, because it can change some files in /nix directory
    # As workaround, import some previous configuration if it exist, otherwise
    # install Android SDK from SDK manager to some writable directory as usual
    # and after that, change SDK in settings
    # You also can temporary configure overlayFS and use them

    # android-studio
    androidSdk
    openjdk
  ];
  shellHook = ''
    export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export ANDROID_USER_HOME="$HOME/.android"
    export ANDROID_AVD_HOME="$HOME/.android/avd"

    # On wayland may not work correctly without this
    export QT_QPA_PLATFORM="xcb"
    # Fix some kind of errors with vulkan
    export LD_LIBRARY_PATH="${pkgs.libglvnd}/lib":$LD_LIBRARY_PATH
  '';
}
