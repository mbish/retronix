{
  pkgs,
  inputs,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "mp64-convert";
  version = "v1.1.1";
  src = inputs.mp64-convert;
  cargoHash = "sha256-6qXwiRaHM4GR3lCW6gVSYK3Yt92JdujtzihZ63hrTQo=";
}
