{inputs, ...}: {
  perSystem = {
    system,
    lib,
    ...
  }: {
    _module.args.pkgs =
      import inputs.nixpkgs
      {
        inherit system;

        overlays = with inputs; [
          # nightly Rust toolchains.
          rust-overlay.overlays.default

          (final: _: {
            # Rust build support library.
            crane = (crane.mkLib final)
              .overrideToolchain final.rust-build;

            # Rust toolchain for builds.
            rust-build =
              final.rust-bin.fromRustupToolchainFile
              ../../rust-toolchain.toml;

            # Rust toolchain for dev.
            rust-dev = final.rust-build.override (prev: {
              extensions =
                lib.unique
                (prev.extensions
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
