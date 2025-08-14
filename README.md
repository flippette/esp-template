# esp-template

opinionated bare-metal async Rust template for the ESP32-C3/C6, or about 300
lines of code I was going to write anyway.

## portability

this template can be built for both the C3 and C6:

- switch between the `esp32c3` and `esp32c6` features in `Cargo.toml`
- switch between the `riscv32imc-unknown-none-elf` and
  `riscv32imac-unknown-none-elf` targets in `.cargo/config.toml`

for ESP32-C6, you should also enable the `ESP_HAL_CONFIG_FLIP_LINK` environment
variable in the `[env]` section of `.cargo/config.toml` (see below).

## other options

besides target support, this template has a few more options:

`Cargo.toml` features:

- `net`: enables Wi-Fi and networking support. (requires `alloc` in `build-std`)
- `mbedtls`: enables TLS support using `esp-mbedtls`. (requires `alloc` in `build-std`)

`.cargo/config.toml` options:

- `build-std`: building the `alloc` crate is optional, but is required for
  certain crate features; disabling this makes cold builds _slightly_ faster.
- `build-std-features`: the `panic_immediate_abort` standard library feature is
  optional, and saves some flash space if you don't want panic backtraces.
- `env`: the `ESP_HAL_CONFIG_FLIP_LINK` environment variable enables zero-cost
  stack overflow protection on ESP32-C6.

## Nix

the Nix flake exports 2 outputs: a dev shell and a package.

the dev shell contains common utilities for development: the Rust toolchain,
`cargo-binutils`, `cargo-bloat`, and `espflash`.

building the package generates an ELF binary, which can be converted into a
flat firmware image using `espflash` and flashed onto a module.

due to an [issue](https://github.com/esp-rs/espflash/issues/935) with
`espflash`, the package doesn't generate this flat firmware image automatically.
this will be done in the future, once the issue is resolved.
