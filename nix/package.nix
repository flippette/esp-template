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
  craneLib' =
    craneLib.overrideToolchain
    toolchain;
in
  craneLib'.buildPackage rec {
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
        (craneLib'.findCargoFiles src)
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

    ESP_HAL_CONFIG_WRITE_VEC_TABLE_MONITORING = "true";
  }
