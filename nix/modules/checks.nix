{
  perSystem = {pkgs, ...}: {
    checks.esp32c3-clippy =
      (pkgs.callPackages ../package.nix {
        chip = "esp32c3";
        target = "riscv32imc-unknown-none-elf";
      }).clippy;

    checks.esp32c6-clippy =
      (pkgs.callPackages ../package.nix {
        chip = "esp32c6";
        target = "riscv32imac-unknown-none-elf";
      }).clippy;
  };
}
