{
  # pkgs
  lib,
  craneLib,
  espflash,
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

    # build dependencies separately to speed up rebuilds.
    cargoArtifacts = craneLib'.buildDepsOnly args;

    # prevent UB from stack overflows.
    env.ESP_HAL_CONFIG_WRITE_VEC_TABLE_MONITORING = "true";
  };
in {
  clippy = craneLib'.cargoClippy (args
    // {
      # otherwise Cargo complains about the `test` crate.
      cargoClippyExtraArgs = "";
    });
  package = craneLib'.buildPackage (args
    // {
      postInstall = ''
        # generate a flat firmware binary (for OTA, etc.)
        ${espflash}/bin/espflash save-image \
          --chip esp32c6 \
          $out/bin/$pname \
          $out/bin/$pname.bin
      '';
    });
}
