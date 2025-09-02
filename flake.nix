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
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      rustBin = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      craneLib = (crane.mkLib pkgs).overrideToolchain rustBin;

      # include additional files relative to the root
      unfilteredRoot = ./.;
      src = with pkgs;
        lib.fileset.toSource {
          root = unfilteredRoot;
          fileset = lib.fileset.unions [
            (craneLib.fileset.commonCargoSources unfilteredRoot)
            # additional files go here
          ];
        };

      commonArgs = {
        inherit src;
        strictDeps = true;

        cargoVendorDir = craneLib.vendorMultipleCargoDeps {
          inherit (craneLib.findCargoFiles src) cargoConfigs;
          cargoLockList = [
            ./Cargo.lock

            # needed for `-Z build-std`
            # <https://crane.dev/examples/build-std.html>
            ("${rustBin.passthru.availableComponents.rust-src}"
              + "/lib/rustlib/src/rust/library/Cargo.lock")
          ];
        };

        doCheck = false;
      };

      c3Args = {
        cargoExtraArgs = pkgs.lib.concatStringsSep " " [
          "--target riscv32imc-unknown-none-elf"
          "--features esp32c3"
        ];
      };
      c6Args = {
        cargoExtraArgs = pkgs.lib.concatStringsSep " " [
          "--target riscv32imac-unknown-none-elf"
          "--features esp32c6"
        ];

        ESP_HAL_CONFIG_FLIP_LINK = "true";
      };

      c3Artifacts = craneLib.buildDepsOnly (commonArgs // c3Args);
      c6Artifacts = craneLib.buildDepsOnly (commonArgs // c6Args);

      c3 = craneLib.buildPackage (commonArgs
        // c3Args
        // {
          cargoArtifacts = c3Artifacts;
        });
      c6 = craneLib.buildPackage (commonArgs
        // c6Args
        // {
          cargoArtifacts = c6Artifacts;
        });
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          cargo-binutils
          cargo-bloat
          espflash
          just
          rustBin
        ];
      };

      packages = {
        inherit c3 c6;
      };

      checks = {
        inherit c3 c6;

        c3-clippy = craneLib.cargoClippy (commonArgs
          // c3Args
          // {
            cargoArtifacts = c3Artifacts;
            cargoClippyExtraArgs = "-- -W clippy::pedantic";
          });

        c6-clippy = craneLib.cargoClippy (commonArgs
          // c3Args
          // {
            cargoArtifacts = c6Artifacts;
            cargoClippyExtraArgs = "-- -W clippy::pedantic";
          });

        deny = craneLib.cargoDeny commonArgs;
      };

      formatter = pkgs.alejandra;
    });
}
