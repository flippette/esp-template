{
  perSystem = {pkgs, ...}: {
    checks = {
      esp32c2-clippy =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c2";
          target = "riscv32imc-unknown-none-elf";
        }).clippy;
      esp32c3-clippy =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c3";
          target = "riscv32imc-unknown-none-elf";
        }).clippy;
      esp32c5-clippy =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c5";
          target = "riscv32imac-unknown-none-elf";
        }).clippy;
      esp32c6-clippy =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c6";
          target = "riscv32imac-unknown-none-elf";
        }).clippy;
      esp32c61-clippy =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c61";
          target = "riscv32imac-unknown-none-elf";
        }).clippy;
      esp32h2-clippy =
        (pkgs.callPackages ../package.nix {
          chip = "esp32h2";
          target = "riscv32imac-unknown-none-elf";
        }).clippy;
    };
  };
}
