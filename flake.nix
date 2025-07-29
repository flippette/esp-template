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

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustBin = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        craneLib = (crane.mkLib pkgs).overrideToolchain rustBin;
        rustTools = with pkgs; [ cargo-binutils cargo-bloat espflash ];
      in with pkgs; {
        devShells.default = mkShell { buildInputs = rustTools ++ [ rustBin ]; };
        packages.default = craneLib.buildPackage {
          pname = "esp-template";
          version = "0.1.0";

          src = craneLib.cleanCargoSource ./.;
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
      });
}
