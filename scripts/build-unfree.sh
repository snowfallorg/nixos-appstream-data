#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

SECTION="${SECTION:-nixos-unstable}"
REV=$(nix flake metadata nixpkgs/$SECTION --json | jq '.revision' -r)

mapfile -t UNFREE_PKGS < unfree-full.txt

mkdir -p workspace-unfree
pushd workspace-unfree

ARCHIVE_ROOT="file://$(pwd)/unfree-store?write-nar-listing=true"

mkdir -p unfree-store
for pkg in "${UNFREE_PKGS[@]}"; do
  echo "Copying $pkg to local store..."
  nix copy --to "$ARCHIVE_ROOT" "../extra-metadata#$pkg" --no-use-registries --override-input nixpkgs "github:nixos/nixpkgs/$REV" || echo "Warning: Failed to copy $pkg, skipping..."
done

cat > asgen-config.json << EOF
{
  "ProjectName": "Nix",
  "ArchiveRoot": "$ARCHIVE_ROOT",
  "Backend": "nix",
  "Features": {
    "processDesktop": true,
    "validateMetainfo": true,
    "createScreenshotsStore": true,
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

mkdir -p "cache/nixpkgs/$REV/x86_64-linux"
NIXPKGS_PATH="$(nix eval nixpkgs/$REV#path)"

nix-env -qaP --out-path --meta --json --file ../scripts/unfree-filter.nix --arg nixpkgsPath "$NIXPKGS_PATH" --arg packageListFile ../unfree-full.txt \
  | jq -c '{version: "2", packages: .}' \
  > "cache/nixpkgs/$REV/x86_64-linux/packages.json"

unbuffer appstream-generator process nixpkgs --verbose 2>&1 | tee appstream-generator.log
popd

rm -rf appstream/"$SECTION"-unfree/data
mkdir -p appstream/"$SECTION"-unfree/data
mv workspace-unfree/export/data/nixpkgs/"$REV"/Components*.gz appstream/"$SECTION"-unfree/data/
mv workspace-unfree/export/data/nixpkgs/"$REV"/icons* appstream/"$SECTION"-unfree/data/
