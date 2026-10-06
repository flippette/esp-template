{
  perSystem = {pkgs, ...}: {
    packages.default =
      (pkgs.callPackage ../scope.nix {
        rust-toolchain = pkgs.rust-minimal-with-src;
      }).firmware;

    checks.clippy =
      (pkgs.callPackage ../scope.nix {}).clippy;
  };
}
