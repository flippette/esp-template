{
  perSystem = {pkgs, ...}: {
    packages = {
      esp32c2 =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c2";
          target = "riscv32imc-unknown-none-elf";
        }).package;
      esp32c3 =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c3";
          target = "riscv32imc-unknown-none-elf";
        }).package;
      esp32c5 =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c5";
          target = "riscv32imac-unknown-none-elf";
        }).package;
      esp32c6 =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c6";
          target = "riscv32imac-unknown-none-elf";
        }).package;
      esp32c61 =
        (pkgs.callPackages ../package.nix {
          chip = "esp32c61";
          target = "riscv32imac-unknown-none-elf";
        }).package;
      esp32h2 =
        (pkgs.callPackages ../package.nix {
          chip = "esp32h2";
          target = "riscv32imac-unknown-none-elf";
        }).package;
    };
  };
}
