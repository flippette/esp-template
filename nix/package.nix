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
    # clean sources to avoid unneeded rebuilds.
    src = lib.fileset.toSource rec {
      root = ../.;
      fileset = lib.fileset.unions [
        (craneLib'.fileset.commonCargoSources root)
        # extra files go here.
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

    # set MCU target and feature flags.
    cargoExtraArgs = lib.concatStringsSep " " [
      "--target ${mcuTarget}"
      "--features ${mcuFeature}"
    ];

    # clear this out, otherwise crane will try to run tests.
    cargoClippyExtraArgs = "";

    # build dependencies separately to speed up rebuilds.
    cargoArtifacts = craneLib'.buildDepsOnly args;

    # prevent UB from stack overflows.
    env.ESP_HAL_CONFIG_WRITE_VEC_TABLE_MONITORING = "true";
  };
in {
  package = craneLib'.buildPackage args;
  clippy = craneLib'.cargoClippy args;
}
