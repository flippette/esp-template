r3 *args:
  cargo run --release \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

r6 *args:
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
  cargo build --release \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

c3 *args:
  cargo clippy \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

c6 *args:
  cargo clippy \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

bl3 *args:
  cargo bloat --release \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

bl6 *args:
  cargo bloat --release \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

d3 *args:
  cargo doc --release \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

d6 *args:
  cargo doc --release \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

cl:
  cargo clean
