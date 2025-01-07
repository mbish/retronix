{pkgs, ...}: rec {
  templateFile = pkgs.callPackage ./template {};
  templateFileToFile = f: path: data:
    pkgs.writeTextFile {
      name = f;
      text = templateFile path data;
    };
}
