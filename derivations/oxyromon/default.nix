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
  cargoHash = "sha256-lFqIVA5KMfSIaHhQ7u3/HoGHErlTSXB6XXQYysKHmzM=";
  cargoBuildFlags = [
    "--workspace"
  ];
  doCheck = false;
}
