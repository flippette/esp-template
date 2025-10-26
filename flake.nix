{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs {inherit system overlays;};
      rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      craneLib = (crane.mkLib pkgs).overrideToolchain rust;

      unfilteredRoot = ./.;
      src = with pkgs;
        lib.fileset.toSource {
          root = unfilteredRoot;
          fileset = lib.fileset.unions [
            (craneLib.fileset.commonCargoSources unfilteredRoot)
            # extra files go here
          ];
        };

      commonArgs = {
        inherit src;
        strictDeps = true;
        doCheck = false;

        cargoVendorDir = craneLib.vendorMultipleCargoDeps {
          inherit (craneLib.findCargoFiles src) cargoConfigs;
          cargoLockList = [
            ./Cargo.lock

            # needed for `-Z build-std`
            # <https://crane.dev/examples/build-std.html>
            ("${rust.passthru.availableComponents.rust-src}"
              + "/lib/rustlib/src/rust/library/Cargo.lock")
          ];
        };

        ESP_HAL_CONFIG_WRITE_VEC_TABLE_MONITORING = "true";
      };
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.cargo-binutils
          pkgs.cargo-bloat
          pkgs.espflash
          pkgs.just
          rust
        ];
      };

      packages = {
        c3 = craneLib.buildPackage (commonArgs
          // {
            cargoExtraArgs = pkgs.lib.concatStringsSep " " [
              "--target riscv32imc-unknown-none-elf"
              "--features esp32c3"
            ];
          });
        c6 = craneLib.buildPackage (commonArgs
          // {
            cargoExtraArgs = pkgs.lib.concatStringsSep " " [
              "--target riscv32imac-unknown-none-elf"
              "--features esp32c6"
            ];
          });
      };

      formatter = pkgs.alejandra;
    });
}
