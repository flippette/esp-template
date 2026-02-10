{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit
      (config.packages)
      esp32c3
      esp32c6
      ;

    esp32c3-dev = esp32c3.override {
      crane =
        pkgs.crane.overrideToolchain
        pkgs.rust-dev;
      rust-build = pkgs.rust-dev;
    };

    esp32c6-dev = esp32c6.override {
      crane =
        pkgs.crane.overrideToolchain
        pkgs.rust-dev;
      rust-build = pkgs.rust-dev;
    };
  in {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.pre-commit.devShell
        esp32c3-dev
        esp32c6-dev
      ];

      packages = with pkgs; [
        cargo-binutils
        cargo-bloat
        espflash
        esptool
        just
      ];

      shellHook = ''
        ${config.pre-commit.shellHook}
      '';
    };
  };
}
