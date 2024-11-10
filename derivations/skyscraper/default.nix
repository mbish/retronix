{
  pkgs,
  inputs,
  ...
}:
pkgs.stdenv.mkDerivation {
  src = inputs.skyscraper;
  name = "skyscraper";
  nativeBuildInputs = [
    pkgs.qt5.wrapQtAppsHook
  ];
  buildInputs = [
    pkgs.qt5.qtbase
  ];
  patches = [
    ./Add-skip-option.diff
  ];
  buildPhase = ''
    qmake -o Makefile skyscraper.pro \
      -late target.path=$out/bin \
      -late examples.path=$out/local/etc/skyscraper \
      -late cacheexamples.path=$out/local/etc/skyscraper/cache \
      -late impexamples.path=$out/local/etc/skyscraper/import  \
      -late resexamples.path=$out/local/etc/skyscraper/resources
    make
  '';
}
