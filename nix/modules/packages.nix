{
  perSystem = {pkgs, ...}: {
    packages.esp32c3 =
      (pkgs.callPackages ../package.nix {
        chip = "esp32c3";
        target = "riscv32imc-unknown-none-elf";
      }).package;

    packages.esp32c6 =
      (pkgs.callPackages ../package.nix {
        chip = "esp32c6";
        target = "riscv32imac-unknown-none-elf";
      }).package;
  };
}
