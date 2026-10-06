{
  lib,
  crane,
  newScope,
  espflash,
  rust-toolchain,
  chip,
  target,
}:
lib.makeScope newScope (self: {
  commonArgs = {
    src = lib.fileset.toSource rec {
      root = ../.;
      fileset = lib.fileset.unions [
        (self.crane.fileset.commonCargoSources root)
        (lib.fileset.maybeMissing (root + "/.secrets.envrc"))
      ];
    };

    strictDeps = true;
    doCheck = false;

    cargoVendorDir = self.crane.vendorMultipleCargoDeps {
      inherit
        (self.crane.findCargoFiles self.commonArgs.src)
        cargoConfigs
        ;
      cargoLockList = let
        inherit (rust-toolchain.passthru) availableComponents;
        inherit (availableComponents) rust-src;
      in [
        "${self.commonArgs.src}/Cargo.lock"
        "${rust-src}/lib/rustlib/src/rust/library/Cargo.lock"
      ];
    };

    cargoExtraArgs = lib.concatStringsSep " " [
      "--features=${self.chip}"
      "--target=${self.target}"
    ];
  };

  cargoArtifacts = self.crane.buildDepsOnly self.commonArgs;

  firmware = self.crane.buildPackage (self.commonArgs
    // {
      inherit (self) cargoArtifacts;
      postFixup = ''
        ${lib.getExe self.espflash} save-image \
          --chip=${self.chip} \
          $out/bin/$pname \
          $out/bin/$pname.bin
      '';
    });

  clippy = self.crane.cargoClippy (self.commonArgs
    // {
      inherit (self) cargoArtifacts;
      cargoClippyExtraArgs = "";
    });

  crane = crane.overrideToolchain self.rust-toolchain;
  inherit espflash rust-toolchain chip target;
})
