{
  set ? "free",
  stdenv ? (import <nixpkgs> { }).stdenv,
  lib ? import <nixpkgs/lib>,
  pkgs ? import <nixpkgs> { },
}:
stdenv.mkDerivation rec {
  pname = "nixos-appstream-data";
  version = "0.1.0";

  buildInputs = with pkgs; [
    appstream
  ];

  src = [ ./. ];

  installPhase = ''
    runHook preInstall

    ./build.sh ${set}

    # Install to modern swcatalog paths (AppStream 1.0+)
    # This is the standard location for OS-provided software catalogs
    mkdir -p $out/share/swcatalog/xml
    mkdir -p $out/share/swcatalog/icons/nixos

    # Copy compressed catalog files
    cp dest/*.gz $out/share/swcatalog/xml/

    # Copy icons with size subdirectories
    cp -r dest/icons/64x64 $out/share/swcatalog/icons/nixos/
    cp -r dest/icons/128x128 $out/share/swcatalog/icons/nixos/

    # Also create legacy app-info symlinks for compatibility with older tools
    mkdir -p $out/share/app-info
    ln -s ../swcatalog/xml $out/share/app-info/xmls
    ln -s ../swcatalog/icons $out/share/app-info/icons

    runHook postInstall
  '';
}
