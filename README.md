# esp-template

opinionated bare-metal async Rust template for the ESP32-C3/C6, or about 250
lines of code I was going to write anyway.

## portability

this template can be built for both the C3 and C6:

- switch between the `esp32c3` and `esp32c6` features in `Cargo.toml`
- switch between the `riscv32imc-unknown-none-elf` and
  `riscv32imac-unknown-none-elf` targets in `.cargo/config.toml`

## Nix

the Nix flake exports 2 outputs: a dev shell and a package.

the dev shell contains common utilities for development: the Rust toolchain,
`cargo-binutils`, `cargo-bloat`, and `espflash`.

building the package generates an ELF binary, which can be converted into a
flat firmware image using `espflash` and flashed onto a module.

due to an [issue](https://github.com/esp-rs/espflash/issues/935) with
`espflash`, the package doesn't generate this flat firmware image automatically.
this will be done in the future, once the issue is resolved.
