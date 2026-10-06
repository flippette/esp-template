# esp-template

opinionated bare-metal async Rust template for the RISC-V
ESP32s.

## target configuration

this template aims to be chip-agnostic, but since most
projects only target one particular ESP32 variant, this is
achieved via editing hard-coded targets and chip features.

to configure this template for a given chip, there are a few
configuration options that need to be changed:

- in `.cargo/config.toml`, set `build.target` to the correct
  target triple,
- in `Cargo.toml`, set the correct chip name in the features
  enabled by `features.default`,
- in `rust-toolchain.toml`, set `targets` to the correct
  target triple.

the corresponding target triples for the supported chips are
shown in the following table.

| chip                  | target triple                   |
| --------------------- | ------------------------------- |
| `esp32c2`, `esp32c3`  | `riscv32imc-unknown-none-elf`   |
| `esp32c6`, `esp32h2`  | `riscv32imac-unknown-none-elf`  |
| `esp32p4`, `esp32s31` | `riscv32imafc-unknown-none-elf` |

this template is configured for the `esp32c6` target by
default.

## Nix

the Nix flake exports a dev shell, some checks, and a
firmware `default` package.

the dev shell contains the Rust toolchain, `cargo-binutils`,
`cargo-bloat`, `espflash`, and `esptool`.

building the package generates an ELF binary, which can be
flashed onto a module using `espflash`.
