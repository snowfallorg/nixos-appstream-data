{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  meson,
  ninja,
  makeWrapper,
  appstream,
  libarchive,
  cairo,
  gdk-pixbuf,
  librsvg,
  freetype,
  fontconfig,
  pango,
  nodejs,
  lmdb,
  curl,
  libxslt,
  libjxl,
  webp-pixbuf-loader,
  libfyaml,
  docbook_xsl,
  docbook_xml_dtd_45,
  onetbb,
  icu,
  inja,
  libxml2,
  catch2_3,
  optipng,
  ffmpeg,
  gnome,
}:

let
  pname = "appstream-generator";
  version = "0.10.1-unstable-2026-02-01";

  src = fetchFromGitHub {
    owner = "vlinkz";
    repo = "appstream-generator";
    rev = "db0da9c301a6eb9862f9341f2c2c0299a080ba67";
    hash = "sha256-hdTECWZkgkXT4QqkHtuZ4IYmlbDZ6ZWAD27pCO/1yjQ=";
  };

  jsDeps = stdenv.mkDerivation {
    name = "appstream-generator-js-deps";
    inherit src;
    sourceRoot = "${src.name}/contrib/setup";

    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      export HOME=$(mktemp -d)
      npm ci --ignore-scripts
    '';

    installPhase = ''
      mkdir -p $out/js/jquery $out/js/flot $out/js/highlight
      install node_modules/jquery/dist/*.min.js -t $out/js/jquery
      install node_modules/jquery-flot/jquery.flot*.js -t $out/js/flot
      install node_modules/highlightjs/*.js -t $out/js/highlight
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-7EWW/oCZc45QD+pAIz5R04/tLTv3YQ74PwBzK5CHrDQ=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    makeWrapper
  ];

  buildInputs = [
    appstream
    libarchive
    lmdb
    curl
    cairo
    gdk-pixbuf
    librsvg
    freetype
    fontconfig
    pango
    inja
    catch2_3
    onetbb
    libfyaml
    icu
    libxml2
    libxslt
  ];

  mesonFlags = [
    "-Ddownload-js=false"
  ];
  mesonBuildType = "release";

  env.GDK_PIXBUF_MODULE_FILE = gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
    extraLoaders = [
      libjxl
      librsvg
      webp-pixbuf-loader
    ];
  };

  postPatch = ''
    substituteInPlace docs/meson.build \
      --replace-fail 'http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl' \
                     '${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl'
    substituteInPlace docs/appstream-generator.1.xml \
      --replace-fail 'http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd' \
                '${docbook_xml_dtd_45}/xml/dtd/docbook/docbookx.dtd'

    mkdir -p data/templates/default/static/js
    cp -r ${jsDeps}/js/* data/templates/default/static/js/
  '';

  postFixup = ''
    wrapProgram $out/bin/appstream-generator \
      --prefix PATH : ${
        lib.makeBinPath [
          optipng
          ffmpeg
        ]
      } \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';
}
