{
  pkgs,
  inputs,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "mp64-convert";
  version = "v1.1.1";
  src = inputs.mp64-convert;
  cargoHash = "sha256-hweaWWgUdir1MZ2AbHC1MSjeRsTGCE0zSlscX97VDgo=";
}
