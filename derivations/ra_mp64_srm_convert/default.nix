{
  pkgs,
  inputs,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "mp64-convert";
  version = "v1.0";
  src = inputs.mp64-convert;
  cargoSha256 = "sha256-34ieaveE3AT0Ugyw/GF04kEzZ70CsdRs22vhMnK57G0=";
}
