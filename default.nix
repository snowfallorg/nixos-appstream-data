{
  section ? "nixos-unstable",
  stdenv,
}:
stdenv.mkDerivation {
  pname = "nixos-appstream-data";
  version = "0.0.1";

  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/swcatalog/{icons/${section},xml}
    cp appstream/${section}/Components-*.xml.gz $out/share/swcatalog/xml/${section}.xml.gz
    for tarball in appstream/${section}/icons-*.tar.gz; do
      size=$(basename "$tarball" .tar.gz | sed 's/icons-//')
      mkdir -p $out/share/swcatalog/icons/${section}/$size
      tar -xzf "$tarball" -C $out/share/swcatalog/icons/${section}/$size/
    done
    runHook postInstall
  '';
}
