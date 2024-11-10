{
  pkgs,
  inputs,
  system,
  ...
}:
(pkgs.makeRustPlatform {
  inherit (inputs.fenix.packages.${system}.minimal) cargo rustc;
})
.buildRustPackage {
  pname = "mp64-convert";
  version = "v1.0";
  src = inputs.mp64-convert;
  cargoSha256 = "sha256-JAdMExVPK8v17owiVlS4wO79DN/IW/PkILqWEQSCBPU=";
}
