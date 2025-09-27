# esp-template

opinionated bare-metal async Rust template for the ESP32-C3/C6, or about 550
lines of code I was going to write anyway.

## portability

this template can be built for both the C3 and C6:

- use `just r3` to flash on C3, and `just r6` to flash on C6.
- use `just b3` to build for C3, and `just b6` to build for C6.
- use `just c3` to run Clippy for C3, and `just c6` to run Clippy for C6.

the Justfile recipes automatically set the required build target, crate
features, and the `ESP_HAL_CONFIG_FLIP_LINK` environment variable. (see below)

## other options

besides target support, this template has a few more options:

`Cargo.toml` features:

- `net`: enables networking support through `embassy-net` (implies `wifi`).
- `wifi`: enables Wi-Fi support (requires `build-std = "alloc"`).

`.cargo/config.toml` options:

- `build-std`: building the `alloc` crate is optional, but is required for
  certain crate features; disabling this makes cold builds _slightly_ faster.
- `build-std-features`: the `panic_immediate_abort` standard library feature is
  optional, and saves some flash space without much downside, if you use
  `defmt::panic!` and co. for panicking.
- `env`:
  - the `ESP_HAL_CONFIG_FLIP_LINK` environment variable enables zero-cost
    stack overflow protection on ESP32-C6.
  - the `ESP_WIFI_CONFIG_COUNTRY_CODE` environment variable sets your Wi-Fi
    country code.

## Nix

the Nix flake exports 4 outputs: a dev shell, some checks, and 2 packages, one
for each chip.

the dev shell contains common utilities for development: the Rust toolchain,
`cargo-binutils`, `cargo-bloat`, `espflash`, and `just`.

building the package generates an ELF binary, which can be converted into a
flat firmware image using `espflash` and flashed onto a module.

due to an [issue](https://github.com/esp-rs/espflash/issues/935) with
`espflash`, the package doesn't generate this flat firmware image automatically.
this will be done in the future, once the issue is resolved.

## branches

to use the version of `esp-hal` currently published on `crates.io`, use the
`main` branch of this template.

`esp-hal` is going to hit `1.0.0-rc.1` _Soon™_. in the meantime, if you want to
use `esp-hal` straight from `git`, use the `esp-hal-git` branch of this
template; it will be kept mostly up-to-date with the `main` branch of `esp-hal`.

blah blahb lah asjf;lkasdjf;lksadf
