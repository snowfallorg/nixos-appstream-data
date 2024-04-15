{
  description = "Appstream data for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
    in rec {
      packages.nixos-appstream-data = pkgs.callPackage ./default.nix {};
      packages.default = packages.nixos-appstream-data;
    });
}
