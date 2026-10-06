{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      inputsFrom =
        lib.attrValues config.packages
        ++ lib.attrValues config.checks;
    };
  };
}
