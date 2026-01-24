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
        config,
        system,
        pkgs,
        ...
      }: let
        craneLib = inputs.crane.mkLib pkgs;
        esp32c3 = pkgs.callPackage ./nix/package.nix {
          inherit craneLib;
          mcuFeature = "esp32c3";
          mcuTarget = "riscv32imc-unknown-none-elf";
        };
        esp32c6 = pkgs.callPackage ./nix/package.nix {
          inherit craneLib;
          mcuFeature = "esp32c6";
          mcuTarget = "riscv32imac-unknown-none-elf";
        };
      in {
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

        pre-commit = with pkgs; {
          check.enable = true;
          settings.package = prek;
          settings.hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            taplo.enable = true;

            rustfmt = {
              enable = true;
              packageOverrides.cargo = rust-dev;
              packageOverrides.rustfmt = rust-dev;
            };
          };
        };

        devShells.default = let
          esp32c3-dev = esp32c3.override {
            toolchain = pkgs.rust-dev;
          };
          esp32c6-dev = esp32c6.override {
            toolchain = pkgs.rust-dev;
          };
        in
          pkgs.mkShell {
            inputsFrom = [
              config.pre-commit.devShell
              esp32c3-dev.package
              esp32c6-dev.package
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

        packages.esp32c3 = esp32c3.package;
        packages.esp32c6 = esp32c6.package;

        checks.clippy-esp32c3 = esp32c3.clippy;
        checks.clippy-esp32c6 = esp32c6.clippy;
      };
    };
}
