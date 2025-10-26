{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
    advisory-db,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs {inherit system overlays;};
      rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      cranelib = (crane.mkLib pkgs).overrideToolchain rust;

      unfilteredRoot = ./.;
      src = with pkgs;
        lib.fileset.toSource {
          root = unfilteredRoot;
          fileset = lib.fileset.unions [
            (cranelib.fileset.commonCargoSources unfilteredRoot)
            # extra files go here
          ];
        };

      commonArgs = {
        inherit src;
        strictDeps = true;
        doCheck = false;

        cargoVendorDir = cranelib.vendorMultipleCargoDeps {
          inherit (cranelib.findCargoFiles src) cargoConfigs;
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
        buildInputs = with pkgs; [
          cargo-binutils
          cargo-bloat
          espflash
          just
          rust
        ];
      };

      packages = {
        c3 = cranelib.buildPackage (commonArgs
          // {
            cargoExtraArgs = pkgs.lib.concatStringsSep " " [
              "--target riscv32imc-unknown-none-elf"
              "--features esp32c3"
            ];
          });
        c6 = cranelib.buildPackage (commonArgs
          // {
            cargoExtraArgs = pkgs.lib.concatStringsSep " " [
              "--target riscv32imac-unknown-none-elf"
              "--features esp32c6"
            ];
          });
      };

      checks = let
        auditArgs = {inherit advisory-db;};
      in {
        audit = cranelib.cargoAudit (commonArgs // auditArgs);
      };

      formatter = pkgs.alejandra;
    });
}
