{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-x-cabal-utils.url = "github:bglgwyng/nix-x-cabal-utils";
    hackage-haskell-org-root-json = {
      url = "file+https://hackage.haskell.org/root.json";
      flake = false;
    };
    reflex = {
      url = "github:reflex-frp/reflex";
      flake = false;
    };
    servant = {
      url = "github:haskell-servant/servant";
      flake = false;
    };
    servant-multipart = {
      url = "github:haskell-servant/servant-multipart";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          inherit (inputs.nix-x-cabal-utils.lib.${system})
            fetch-hackage-index-at
            generate-packages-nix
            generate-package-set
            generate-repos-config
            ;
          repos-config = generate-repos-config {
            active-repositories = [
              "hackage.haskell.org"
              "local:override"
            ];
            repositories = {
              "hackage.haskell.org".remote = {
                url = "https://hackage.haskell.org/";
                secure = true;
                "01-index-tar" = fetch-hackage-index-at {
                  repoUrl = "https://hackage.haskell.org/";
                  indexState = "2026-10-21T00:00:00Z";
                  hash = "sha256-VtbQPfzTQJg9i9mQpXgrSIWoFZT3cUlspAUDqRKPJEE=";
                };
                root-json = inputs.hackage-haskell-org-root-json;
              };
              local.local = import ./local.nix { inherit inputs; };
            };
          };
          ghc9141-packages-nix = generate-packages-nix {
            package-set = generate-package-set {
              ghc = "${pkgs.haskell.compiler.ghc9141}/bin/ghc";
              ghc-pkg = "${pkgs.haskell.compiler.ghc9141}/bin/ghc-pkg";
              packages-config = builtins.fromJSON (builtins.readFile ./packages.config.json);
              inherit repos-config;
            };
          };
        in
        {
          legacyPackages.haskellPackages = pkgs.callPackage "${pkgs.path}/pkgs/development/haskell-modules" {
            haskellLib = pkgs.haskell.lib.compose;
            ghc = pkgs.buildPackages.haskell.compiler.ghc9141;
            buildHaskellPackages = pkgs.buildPackages.haskell.packages.ghc9141;
            initialPackages = import ghc9141-packages-nix;

            nonHackagePackages = { pkgs, haskellLib }: self: super: { };
            configurationCommon = { pkgs, haskellLib }: self: super: {
              libtorch-ffi = haskellLib.overrideCabal (old: {
                preConfigure = ''
                  export LIBTORCH_SKIP_DOWNLOAD=1
                '';
              }) super.libtorch-ffi;
            };

            configurationNix = import "${pkgs.path}/pkgs/development/haskell-modules/configuration-nix.nix";
            configurationArm = import "${pkgs.path}/pkgs/development/haskell-modules/configuration-arm.nix";
            configurationDarwin =
              { pkgs, haskellLib }:
              pkgs.lib.composeManyExtensions [
                (import "${pkgs.path}/pkgs/development/haskell-modules/configuration-darwin.nix" {
                  inherit pkgs haskellLib;
                })
                (self: super: {
                  hasktorch = haskellLib.overrideCabal (old: {
                    preBuild = (old.preBuild or "") + ''
                      export DYLD_LIBRARY_PATH="${pkgs.llvmPackages.openmp}/lib''${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
                    '';
                  }) super.hasktorch;
                })
              ];
            configurationWindows = import "${pkgs.path}/pkgs/development/haskell-modules/configuration-windows.nix";
            configurationJS = import "${pkgs.path}/pkgs/development/haskell-modules/configuration-ghcjs-9.x.nix";
          };

          devShells.default = pkgs.mkShell {
            packages = [
              (config.legacyPackages.haskellPackages.ghcWithPackages (
                p:
                map (x: p.${x}) (
                  builtins.attrNames (builtins.fromJSON (builtins.readFile ./packages.config.json)).packages
                )
              ))
            ];
          };
        };
    };
}
