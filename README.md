# esp-template

opinionated bare-metal async Rust template for the
ESP32-C3/C6, or about 650 lines of code I was going to write
anyway.

## portability

this template can be built for both the ESP32-C3 and
ESP32-C6:

- use `just r3` or `just r6` to flash and monitor.
- use `just b3` or `just r6` to build.
- use `just c3` or `just c6` to run Clippy.
- use `just bl3` or `just bl6` to run `cargo-bloat`.

the Justfile recipes automatically set the required build
target and crate features.

## Nix

the Nix flake exports a dev shell, some checks, and 2
packages, one per target.

the dev shell contains common utilities for development: the
Rust toolchain, `cargo-binutils`, `cargo-bloat`, `espflash`,
`esptool`, and `just`.

building the package generates an ELF binary and a flat
firmware image, the latter of which can be flashed onto a
module.
