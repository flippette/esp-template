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
      };

      c3TargetArgs = {
        cargoExtraArgs = pkgs.lib.concatStringsSep " " [
          "--target riscv32imc-unknown-none-elf"
          "--features esp32c3"
        ];
      };
      c6TargetArgs = {
        cargoExtraArgs = pkgs.lib.concatStringsSep " " [
          "--target riscv32imac-unknown-none-elf"
          "--features esp32c6"
        ];

        ESP_HAL_CONFIG_FLIP_LINK = "true";
      };

      c3Artifacts = cranelib.buildDepsOnly (commonArgs // c3TargetArgs);
      c6Artifacts = cranelib.buildDepsOnly (commonArgs // c6TargetArgs);

      c3Args = c3TargetArgs // {cargoArtifacts = c3Artifacts;};
      c6Args = c6TargetArgs // {cargoArtifacts = c6Artifacts;};

      c3-build = cranelib.buildPackage (commonArgs // c3Args);
      c6-build = cranelib.buildPackage (commonArgs // c6Args);
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
        inherit c3-build c6-build;
      };

      checks = let
        clippyArgs = {cargoClippyExtraArgs = "-- -Wclippy::pedantic";};
        auditArgs = {inherit advisory-db;};
      in {
        inherit c3-build c6-build;

        c3-clippy = cranelib.cargoClippy (commonArgs // c3Args // clippyArgs);
        c6-clippy = cranelib.cargoClippy (commonArgs // c6Args // clippyArgs);

        audit = cranelib.cargoAudit (commonArgs // auditArgs);
        deny = cranelib.cargoDeny commonArgs;
      };

      formatter = pkgs.alejandra;
    });
}
