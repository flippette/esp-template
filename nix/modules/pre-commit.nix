{inputs, ...}: {
  imports = with inputs; [
    git-hooks.flakeModule
  ];

  perSystem = {pkgs, ...}: {
    pre-commit = with pkgs; {
      check.enable = true;
      settings.package = prek;
      settings.hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        taplo.enable = true;

        rustfmt.enable = true;
        rustfmt.packageOverrides = {
          cargo = rust-dev;
          rustfmt = rust-dev;
        };
      };
    };
  };
}
