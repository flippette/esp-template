{lib, ...}: {
  perSystem = {pkgs, ...}: let
    riscv32imc = "riscv32imc-unknown-none-elf";
    riscv32imac = "riscv32imac-unknown-none-elf";
    targets = {
      esp32c2 = riscv32imc;
      esp32c3 = riscv32imc;
      esp32c5 = riscv32imac;
      esp32c6 = riscv32imac;
      esp32c61 = riscv32imac;
      esp32h2 = riscv32imac;
    };

    make-esp-template = rust-toolchain:
      lib.genAttrs (lib.attrNames targets) (chip:
        pkgs.callPackage ../scope.nix {
          inherit chip rust-toolchain;
          target = targets.${chip};
        });
  in {
    packages =
      lib.mapAttrs (_: scope: scope.firmware)
      (make-esp-template pkgs.rust-build);
    checks =
      lib.mapAttrs (_: scope: scope.clippy)
      (make-esp-template pkgs.rust-dev);
  };
}
