# esp-template

opinionated bare-metal async Rust template for the RISC-V
ESP32s, or about 650 lines of code I was going to write
anyway.

## portability

this template needs to be built with the correct target arch
_and_ MCU feature enabled. the Justfile sets these
automatically, read it for details.

## Nix

the Nix flake exports a dev shell, some checks, and one
package per MCU target.

the dev shell contains common utilities for development: the
Rust toolchain, `cargo-binutils`, `cargo-bloat`, `espflash`,
`esptool`, and `just`.

building the package generates an ELF binary and a flat
firmware image, the latter of which can be flashed onto a
module.
