# esp-template

opinionated bare-metal async Rust template for the ESP32-C3/C6, or about 450
lines of code I was going to write anyway.

## portability

this template can be built for both the C3 and C6:

- use `just r3` to flash on C3, and `just r6` to flash on C6.
- use `just b3` to build for C3, and `just b6` to build for C6.
- use `just c3` to run Clippy for C3, and `just c6` to run Clippy for C6.

the Justfile recipes automatically set the required build target and crate
features.

## Nix

the Nix flake exports 4 outputs: a dev shell, some checks, and 2 packages, one
for each chip.

the dev shell contains common utilities for development: the Rust toolchain,
`bacon`, `cargo-binutils`, `cargo-bloat`, `espflash`, and `just`.

building the package generates an ELF binary, which can be converted into a
flat firmware image using `espflash` and flashed onto a module.

due to an [issue](https://github.com/esp-rs/espflash/issues/935) with
`espflash`, the package doesn't generate this flat firmware image automatically.
this will be done in the future, once the issue is resolved.
