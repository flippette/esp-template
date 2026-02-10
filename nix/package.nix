{
  # pkgs
  lib,
  crane,
  espflash,
  rust-build,
  # options
  chip,
  target,
}: let
  args = {
    # clean sources to avoid unneeded rebuilds.
    src = lib.fileset.toSource rec {
      root = ../.;
      fileset = lib.fileset.unions [
        (crane.fileset.commonCargoSources root)
        (lib.fileset.maybeMissing ../.secrets.envrc)
      ];
    };

    strictDeps = true;
    doCheck = false;

    cargoVendorDir = crane.vendorMultipleCargoDeps {
      inherit (crane.findCargoFiles args.src) cargoConfigs;

      cargoLockList = [
        ../Cargo.lock

        # needed for `-Z build-std`
        # <https://crane.dev/examples/build-std.html>
        ("${rust-build.passthru.availableComponents.rust-src}"
          + "/lib/rustlib/src/rust/library/Cargo.lock")
      ];
    };

    # set MCU target and feature flags.
    cargoExtraArgs = lib.concatStringsSep " " [
      "--features ${chip}"
      "--target ${target}"
    ];

    # build dependencies separately to speed up rebuilds.
    cargoArtifacts = crane.buildDepsOnly args;
  };
in {
  clippy = crane.cargoClippy (args
    // {
      # otherwise Cargo complains about the `test` crate.
      cargoClippyExtraArgs = "";
    });
  package = crane.buildPackage (args
    // {
      postInstall = ''
        # generate a flat firmware binary (for OTA, etc.)
        ${espflash}/bin/espflash save-image \
          --chip ${chip} \
          $out/bin/$pname \
          $out/bin/$pname.bin
      '';
    });
}
