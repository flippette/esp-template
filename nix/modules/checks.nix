{
  perSystem = {pkgs, ...}:
    with pkgs; let
      src = nix-gitignore.gitignoreSource [] ../../.;
    in {
      checks = {
        alejandra = runCommand "alejandra" {
          inherit src;
          nativeBuildInputs = [alejandra];
        } "alejandra --check $src && touch $out";

        deadnix = runCommand "deadnix" {
          inherit src;
          nativeBuildInputs = [deadnix];
        } "deadnix $src && touch $out";

        statix = runCommand "statix" {
          inherit src;
          nativeBuildInputs = [statix];
        } "statix check $src && touch $out";

        taplo = runCommand "taplo" {
          inherit src;
          nativeBuildInputs = [taplo];
        } "taplo format --check $src && touch $out";

        rustfmt = runCommand "rustfmt" {
          inherit src;
          nativeBuildInputs = [rust-dev];
        } "cd $src && cargo fmt --check && touch $out";
      };
    };
}
