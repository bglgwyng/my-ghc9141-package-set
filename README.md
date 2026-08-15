# my-ghc9141-package-set

This is a package set for GHC 9.14.1 containing the packages I need.
It uses [nix-x-cabal-utils](https://github.com/bglgwyng/nix-x-cabal-utils) to resolve the dependency graph and generate Nix packages.

To configure the package set, edit [packages.config.json](./packages.config.json) and [local.nix](./local.nix).

Use the generated packages through `inputs'.my-ghc9141-package-set.legacyPackages.haskellPackages`.

For a package definition (instead of `pkgs.haskellPackages`):

```nix
{
  perSystem = { inputs', ... }:
    let
      haskellPackages =
        inputs'.my-ghc9141-package-set.legacyPackages.haskellPackages;
    in
    {
      packages.my-package = haskellPackages.callPackage ./package.nix { };
    };
}
```

With `haskell-flake`:

```nix
{
  perSystem = { inputs', ... }:
    {
      haskellProjects.default = {
        basePackages =
          inputs'.my-ghc9141-package-set.legacyPackages.haskellPackages;
      };
    };
}
```
