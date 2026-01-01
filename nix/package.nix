{
  # pkgs
  lib,
  craneLib,
  rust-build,
  # options
  toolchain ? rust-build,
  mcuFeature,
  mcuTarget,
  ...
}: let
  craneLib' = craneLib.overrideToolchain toolchain;

  args = {
    # ===== core attrs =====

    src = lib.fileset.toSource rec {
      root = ../.;
      fileset = lib.fileset.unions [
        (craneLib'.fileset.commonCargoSources root)
        # extra files go here
      ];
    };

    strictDeps = true;
    doCheck = false;

    cargoVendorDir = craneLib'.vendorMultipleCargoDeps {
      inherit
        (craneLib'.findCargoFiles args.src)
        cargoConfigs
        ;

      cargoLockList = [
        ../Cargo.lock

        # needed for `-Z build-std`
        # <https://crane.dev/examples/build-std.html>
        ("${toolchain.passthru.availableComponents.rust-src}"
          + "/lib/rustlib/src/rust/library/Cargo.lock")
      ];
    };

    cargoExtraArgs = lib.concatStringsSep " " [
      "--target ${mcuTarget}"
      "--features ${mcuFeature}"
    ];

    cargoArtifacts = craneLib'.buildDepsOnly args;

    ESP_HAL_CONFIG_WRITE_VEC_TABLE_MONITORING = "true";

    # ===== cargo clippy =====

    # by default this is set to `--all-targets`, which builds tests.
    cargoClippyExtraArgs = "";
  };
in {
  build = craneLib'.buildPackage args;
  clippy = craneLib'.cargoClippy args;
}
