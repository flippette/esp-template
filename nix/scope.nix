{
  lib,
  crane,
  newScope,
  rust-toolchain,
}:
lib.makeScope newScope (self: {
  crane = crane.overrideToolchain self.rust-toolchain;
  inherit rust-toolchain;

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

    cargoArtifacts =
      self.crane.buildDepsOnly self.commonArgs;

    passthru = {
      inherit (self) commonArgs crane rust-toolchain;
    };
  };

  firmware = self.crane.buildPackage self.commonArgs;

  clippy =
    self.crane.cargoClippy
    (self.commonArgs // {cargoClippyExtraArgs = "";});
})
