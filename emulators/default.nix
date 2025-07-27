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
      ./ares
      ./dolphin
      ./flycast
      ./mednafen
      ./melonDS
      ./azahar
      ./mupen64plus
      ./pcsx2
      ./retroarch-beetle-psx
      ./retroarch-parallel-64
      ./rpcs3
      ./snes9x-gtk
    ];
  }
