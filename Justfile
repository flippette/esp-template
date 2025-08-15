r3 *args:
  cargo run --release \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

r6 *args:
  ESP_HAL_CONFIG_FLIP_LINK=true \
  cargo run --release \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

b3 *args:
  cargo build --release \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

b6 *args:
  ESP_HAL_CONFIG_FLIP_LINK=true \
  cargo build --release \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

c3 *args:
  cargo clippy --release \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

c6 *args:
  ESP_HAL_CONFIG_FLIP_LINK=true \
  cargo clippy --release \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

cl:
  cargo clean
