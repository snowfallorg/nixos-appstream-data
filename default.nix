{
stdenv ? (import <nixpkgs> {}).stdenv,
lib ? import <nixpkgs/lib>
}:
stdenv.mkDerivation rec {
  pname = "nixos-appstream-data";
  version = "0.0.1";

  src = [ ./. ];

  installPhase = ''
    runHook preInstall
    ./build.sh
    mkdir -p $out/share/app-info/{icons/nixos,xmls}
    cp dest/*.gz $out/share/app-info/xmls/
    cp -r dest/icons/64x64 $out/share/app-info/icons/nixos/
	cp -r dest/icons/128x128 $out/share/app-info/icons/nixos/
    runHook postInstall
  '';
}
