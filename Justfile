c2 cmd *args:
  cargo {{cmd}} \
    --target riscv32imc-unknown-none-elf \
    --features esp32c2 \
    {{args}}

c3 cmd *args:
  cargo {{cmd}} \
    --target riscv32imc-unknown-none-elf \
    --features esp32c3 \
    {{args}}

c5 cmd *args:
  cargo {{cmd}} \
    --target riscv32imac-unknown-none-elf \
    --features esp32c5 \
    {{args}}

c6 cmd *args:
  cargo {{cmd}} \
    --target riscv32imac-unknown-none-elf \
    --features esp32c6 \
    {{args}}

c61 cmd *args:
  cargo {{cmd}} \
    --target riscv32imac-unknown-none-elf \
    --features esp32c61 \
    {{args}}

h2 cmd *args:
  cargo {{cmd}} \
    --target riscv32imac-unknown-none-elf \
    --features esp32h2 \
    {{args}}

cl:
  cargo clean
