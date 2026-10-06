{
  lib,
  inputs,
  ...
}: {
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      overlays = [
        inputs.rust-overlay.overlays.default

        (final: _: {
          crane = inputs.crane.mkLib final;

          rust-build =
            final.rust-bin.fromRustupToolchainFile
            ../../rust-toolchain.toml;

          rust-dev = final.rust-build.override (prev: {
            extensions = lib.unique (prev.extensions
              ++ [
                "clippy"
                "llvm-tools"
                "rust-analyzer"
                "rustfmt"
              ]);
          });
        })
      ];
    };
  };
}
