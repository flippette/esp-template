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

      # common args between the C3 and C6 packages
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

      c3Args =
        commonArgs
        // {
          cargoExtraArgs = pkgs.lib.concatStringsSep " " [
            "--target riscv32imc-unknown-none-elf"
            "--features esp32c3"
          ];
        };

      c6Args =
        commonArgs
        // {
          cargoExtraArgs = pkgs.lib.concatStringsSep " " [
            "--target riscv32imac-unknown-none-elf"
            "--features esp32c6"
          ];

          ESP_HAL_CONFIG_FLIP_LINK = "true";
        };

      c3-deps = craneLib.buildDepsOnly c3Args;
      c6-deps = craneLib.buildDepsOnly c6Args;

      c3-clippy = craneLib.cargoClippy (c3Args
        // {
          cargoArtifacts = c3-deps;
          cargoClippyExtraArgs = "-- -W clippy::pedantic";
        });
      c6-clippy = craneLib.cargoClippy (c6Args
        // {
          cargoArtifacts = c6-deps;
          cargoClippyExtraArgs = "-- -W clippy::pedantic";
        });

      cx-deny = craneLib.cargoDeny commonArgs;

      c3 =
        craneLib.buildPackage (c3Args
          // {cargoArtifacts = c3-deps;});
      c6 =
        craneLib.buildPackage (c6Args
          // {cargoArtifacts = c6-deps;});
    in
      with pkgs; {
        devShells.default = mkShell {
          buildInputs = [cargo-binutils cargo-bloat espflash just rustBin];
        };

        packages = {
          inherit c3 c6;
        };

        checks = {
          inherit c3-clippy c6-clippy;
          inherit cx-deny;
          inherit c3 c6;
        };

        formatter = alejandra;
      });
}
