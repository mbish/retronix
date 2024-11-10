{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.emulators;
in
  with lib; {
    imports = [
      ./pcsx2
      ./flycast
      ./mednafen
      ./snes9x-gtk
      ./dolphin
      ./mupen64plus
      ./rpcs3
      ./retroarch-beetle-psx
      ./retroarch-parallel-64
    ];
  }
