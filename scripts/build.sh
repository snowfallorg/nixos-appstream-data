#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

SECTION="${SECTION:-nixos-unstable}"
REV=$(nix flake metadata nixpkgs/$SECTION --json | jq '.revision' -r)
ENABLE_NAR_CACHE="${ENABLE_NAR_CACHE:-true}"

if [[ "$ENABLE_NAR_CACHE" == "true" ]]; then
  ARCHIVE_ROOT="https://cache.nixos.org?local-nar-cache=./narcache"
else
  ARCHIVE_ROOT="https://cache.nixos.org"
fi

mkdir -p workspace

cat > workspace/asgen-config.json << EOF
{
  "ProjectName": "Nix",
  "ArchiveRoot": "$ARCHIVE_ROOT",
  "Backend": "nix",
  "Features": {
    "processDesktop": true,
    "validateMetainfo": true,
    "createScreenshotsStore": false,
    "noDownloads": false
  },
  "Suites": {
    "nixpkgs": {
      "sections": [
        "$REV"
      ],
      "architectures": [
        "x86_64-linux"
      ]
    }
  }
}
EOF

pushd workspace
unbuffer appstream-generator process nixpkgs --verbose 2>&1 | tee appstream-generator.log
popd

rm -rf appstream/"$SECTION"
mkdir -p appstream/"$SECTION"
cp workspace/export/data/nixpkgs/"$REV"/Components*.gz appstream/"$SECTION"/
cp workspace/export/data/nixpkgs/"$REV"/icons* appstream/"$SECTION"/

for f in appstream/"$SECTION"/Components*.gz; do
  gunzip "$f"
  sed -i "s/origin=\"[^\"]*\"/origin=\"$SECTION\"/" "${f%.gz}"
  gzip "${f%.gz}"
done
