{
  inputs,
  pkgs,
  ...
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "oxyromon";
  version = "develop";
  nativeBuildInputs = [pkgs.pkg-config pkgs.cmake];
  buildInputs = [pkgs.openssl pkgs.zip pkgs.unzip pkgs.p7zip pkgs.fuse pkgs.fuse3];

  src = inputs.oxyromon;
  cargoSha256 = "sha256-t/6nMYqwAMB6PitkiHTz1dJ9M0Kh7sHTkNUwRzNKwEQ=";
  cargoBuildFlags = [
    "--workspace"
  ];
  doCheck = false;
}
