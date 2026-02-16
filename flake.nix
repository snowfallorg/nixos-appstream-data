{
  description = "Appstream data for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSupportedSystems = nixpkgs.lib.genAttrs supportedSystems;

      overlay = final: prev: {
        appstream = prev.appstream.overrideAttrs (old: rec {
          version = "1.1.2";
          src = prev.fetchFromGitHub {
            owner = "ximion";
            repo = "appstream";
            rev = "v${version}";
            sha256 = "sha256-tvdWWdL6PthffAZZnNZ3+17/eJdZFx8xFkqm7IvyPWE=";
          };
          patches = final.lib.init old.patches;
          buildInputs =
            old.buildInputs
            ++ (with prev; [
              libfyaml
              bash-completion
            ]);
        });
        inja = prev.inja.overrideAttrs (old: {
          patches = [
            # https://github.com/pantor/inja/pull/317
            (prev.fetchpatch {
              name = "cmake-install-pc.patch";
              url = "https://github.com/pantor/inja/commit/ebb7aeb3ae49ccb49a642aaecb0d41483078b8bd.patch";
              hash = "sha256-Cz0EbYwGwFcfhKd8lJzXDy2DpMAcHkz7EC/vVFV60c0=";
            })
          ];
        });
        appstream-generator = final.callPackage ./appstream-generator.nix { };
      };

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
    in
    {
      packages = forAllSupportedSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        let
          appstream-data = pkgs.callPackage ./default.nix { };
          appstream-data-unfree = pkgs.callPackage ./default.nix { section = "nixos-unstable-unfree"; };
          appstream-data-all = pkgs.symlinkJoin {
            name = "nixos-appstream-data-all";
            paths = [
              appstream-data
              appstream-data-unfree
            ];
          };
        in
        {
          inherit appstream-data appstream-data-unfree appstream-data-all;
          inherit (pkgs) appstream-generator;
        }
      );

      devShells = forAllSupportedSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.appstream-generator
              pkgs.shellcheck
            ];
          };
        }
      );
    };
}
