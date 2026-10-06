{
  perSystem = {pkgs, ...}: let
    src = ../../.;
  in {
    checks = {
      alejandra = pkgs.runCommand "alejandra" {
        inherit src;
        nativeBuildInputs = [pkgs.alejandra];
      } "alejandra --check $src && touch $out";

      deadnix = pkgs.runCommand "deadnix" {
        inherit src;
        nativeBuildInputs = [pkgs.deadnix];
      } "deadnix $src && touch $out";

      statix = pkgs.runCommand "statix" {
        inherit src;
        nativeBuildInputs = [pkgs.statix];
      } "statix check $src && touch $out";

      taplo = pkgs.runCommand "taplo" {
        inherit src;
        nativeBuildInputs = [pkgs.taplo];
      } "cd $src && taplo fmt --check && touch $out";

      rustfmt = pkgs.runCommand "rustfmt" {
        inherit src;
        nativeBuildInputs = [pkgs.rust-toolchain];
      } "cd $src && cargo fmt --check && touch $out";
    };
  };
}
