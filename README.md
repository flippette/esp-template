# esp-template

opinionated bare-metal async Rust template for the
ESP32-C3/C6, or about 650 lines of code I was going to write
anyway.

## portability

this template can be built for both the ESP32-C3 and
ESP32-C6:

- use `just r3` to flash on C3, and `just r6` to flash on
  ESP32-C6.
- use `just b3` to build for C3, and `just b6` to build for
  ESP32-C6.
- use `just c3` to run Clippy for C3, and `just c6` to run
  Clippy for ESP32-C6.

the Justfile recipes automatically set the required build
target and crate features.

## Nix

the Nix flake exports a dev shell, some checks, and 2
packages, one per target.

the dev shell contains common utilities for development: the
Rust toolchain, `bacon`, `cargo-binutils`, `cargo-bloat`,
`espflash`, `esptool`, and `just`.

building the package generates an ELF binary and a flat
firmware image, the latter of which can be flashed onto a
module.
