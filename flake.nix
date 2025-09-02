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

      # base build flags, with LTO
      buildArgs = {
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

      # LTO disable override
      ciArgs = {
        CARGO_PROFILE_RELEASE_LTO = "false";
      };

      # c3-specific cargo flags
      c3Args = {
        cargoExtraArgs = pkgs.lib.concatStringsSep " " [
          "--target riscv32imc-unknown-none-elf"
          "--features esp32c3"
        ];
      };

      # c6-specific cargo flags
      c6Args = {
        cargoExtraArgs = pkgs.lib.concatStringsSep " " [
          "--target riscv32imac-unknown-none-elf"
          "--features esp32c6"
        ];

        ESP_HAL_CONFIG_FLIP_LINK = "true";
      };

      # these are only really useful in CI
      c3Artifacts = craneLib.buildDepsOnly (buildArgs // ciArgs // c3Args);
      c6Artifacts = craneLib.buildDepsOnly (buildArgs // ciArgs // c6Args);

      # run clippy for both outputs
      c3-clippy = craneLib.cargoClippy (buildArgs
        // ciArgs
        // c3Args
        // {
          cargoArtifacts = c3Artifacts;
          cargoClippyExtraArgs = "-- -W clippy::pedantic";
        });
      c6-clippy = craneLib.cargoClippy (buildArgs
        // ciArgs
        // c6Args
        // {
          cargoArtifacts = c6Artifacts;
          cargoClippyExtraArgs = "-- -W clippy::pedantic";
        });

      # run cargo-deny for all features
      cx-deny = craneLib.cargoDeny (buildArgs // ciArgs);

      # build without LTO in CI
      c3-ci = craneLib.buildPackage (buildArgs
        // ciArgs
        // c3Args
        // {
          cargoArtifacts = c3Artifacts;
        });
      c6-ci = craneLib.buildPackage (buildArgs
        // ciArgs
        // c6Args
        // {
          cargoArtifacts = c6Artifacts;
        });

      # build with LTO for release
      c3 = craneLib.buildPackage (buildArgs
        // c3Args
        // {
          cargoArtifacts = c3Artifacts;
        });
      c6 = craneLib.buildPackage (buildArgs
        // c6Args
        // {
          cargoArtifacts = c6Artifacts;
        });
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
          inherit c3-ci c6-ci;
          inherit cx-deny;
        };

        formatter = alejandra;
      });
}
