{...}: {
  # Android emulator don't work proper on wayland
  # Enable xwayland
  wayland.windowManager.sway.xwayland = true;
  wayland.windowManager.river.xwayland.enable = true;
  wayland.windowManager.hyprland.xwayland.enable = true;
}