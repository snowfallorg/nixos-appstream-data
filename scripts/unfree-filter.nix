{ nixpkgsPath, packageListFile }:
let
  pkgs = import nixpkgsPath {
    config = import (nixpkgsPath + "/pkgs/top-level/packages-config.nix");
    overlays = [ (import ../extra-metadata/metainfo.nix) ];
  };
  lib = pkgs.lib;

  wanted = builtins.filter (x: x != "") (lib.splitString "\n" (builtins.readFile packageListFile));

  getByPath = path: lib.attrByPath (lib.splitString "." path) null pkgs;

  setByPath = path: lib.setAttrByPath (lib.splitString "." path) (getByPath path);

  merged = lib.foldl' lib.recursiveUpdate { } (map setByPath wanted);
  markRecursive =
    attrs:
    lib.mapAttrs (
      name: value:
      if lib.isDerivation value then
        value
      else if lib.isAttrs value then
        lib.recurseIntoAttrs (markRecursive value)
      else
        value
    ) attrs;
in
markRecursive merged
