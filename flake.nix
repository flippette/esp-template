{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    crane.url = "github:ipetkov/crane";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.git-hooks-nix.flakeModule
      ];

      perSystem = {
        self',
        config,
        system,
        pkgs,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.rust-overlay.overlays.default
            (final: _: {
              # toolchain for builds
              rust-build =
                final.rust-bin.fromRustupToolchainFile
                ./rust-toolchain.toml;

              # toolchain for development
              rust-dev = final.rust-build.override (prev: {
                extensions = final.lib.unique (prev.extensions
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

        pre-commit = {
          check.enable = true;
          settings.package = pkgs.prek;
          settings.hooks = {
            alejandra.enable = true;

            rustfmt = {
              enable = true;
              packageOverrides.cargo = pkgs.rust-dev;
              packageOverrides.rustfmt = pkgs.rust-dev;
            };

            taplo.enable = true;
          };
        };

        devShells.default = let
          esp32c3-dev =
            self'.packages.esp32c3.override
            {toolchain = pkgs.rust-dev;};

          esp32c6-dev =
            self'.packages.esp32c6.override
            {toolchain = pkgs.rust-dev;};
        in
          pkgs.mkShell {
            inputsFrom = [
              config.pre-commit.devShell
              esp32c3-dev
              esp32c6-dev
            ];

            packages = with pkgs; [
              bacon
              cargo-binutils
              cargo-bloat
              espflash
              just
            ];

            shellHook = ''
              ${config.pre-commit.shellHook}
            '';
          };

        packages = let
          craneLib =
            inputs.crane.mkLib
            pkgs;
        in {
          esp32c3 =
            pkgs.callPackage
            ./nix/package.nix {
              inherit craneLib;
              mcuFeature = "esp32c3";
              mcuTarget = "riscv32imc-unknown-none-elf";
            };
          esp32c6 =
            pkgs.callPackage
            ./nix/package.nix {
              inherit craneLib;
              mcuFeature = "esp32c6";
              mcuTarget = "riscv32imac-unknown-none-elf";
            };
        };
      };
    };
}
