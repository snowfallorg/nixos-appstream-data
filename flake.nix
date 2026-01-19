{
  description = "AppStream catalog data for NixOS/nixpkgs packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          # Free packages only (default)
          default = pkgs.callPackage ./default.nix { set = "free"; };
          free = pkgs.callPackage ./default.nix { set = "free"; };

          # Unfree packages only
          unfree = pkgs.callPackage ./default.nix { set = "unfree"; };

          # All packages (free + unfree)
          all = pkgs.callPackage ./default.nix { set = "all"; };
        };
      }
    );
}
