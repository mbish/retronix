{
  pkgs,
  inputs,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  # need to use type=git and submodules=true in the flake
  # need to make this a flake with nixGL as an input
  pname = "pegasus-frontend";
  version = "weekly_2024w38";

  src = inputs.pegasus-frontend;

  buildInputs = [
    pkgs.cmake
    pkgs.SDL2
    pkgs.qt5.qtbase
    pkgs.qt5.qtsvg
    pkgs.qt5.qtgamepad
    pkgs.clang
    pkgs.qt5.qmake
    pkgs.qt5.qtmultimedia
    pkgs.qt5.qttools
    pkgs.qt5.wrapQtAppsHook
    pkgs.qt5.qtgraphicaleffects
  ];
  nativeBuildInputs = [
    pkgs.qt5.wrapQtAppsHook
    # (pkgs.writeShellScriptBin "git" ''
    #   echo "${self.rev or "dirty"}"
    # '')
  ];

  configurePhase = ''
    mkdir build-dir
    cd build-dir && cmake ../
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv src/app/pegasus-fe $out/bin
  '';
}
