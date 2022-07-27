#!/bin/sh

VERSION="unstable"
ARCH="x86_64_linux"

if [ "$1" != "free" -a "$1" != "unfree" -a "$1" != "all" ]; then
    echo "Usage: $0 [free|unfree|all]"
    exit 1
fi
set -e
rm -rf "dest"
mkdir -p "dest"
touch "dest/nixos_${VERSION}_${ARCH}.xml"

combine() {
    cp -r "$1/icons" "dest/"
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <components version=\"0.14\" origin=\"nixos-${VERSION}\">" > "dest/nixos_${VERSION}_${ARCH}.xml"
    find "$1/metadata" -type f -name "*.xml" | sort | while read file; do
        sed -e 's/<application>/<component type="desktop-application">/g' "$file" | sed -e 's/<\/application>/<\/component>/g' |
        sed -e 's/<component>/<component type="desktop-application">/g' | sed -n -e '/<component/,$p' |
        sed 's/^/  /' | sed -e '$a\' >> "dest/nixos_${VERSION}_${ARCH}.xml"
    done
    echo "</components>" >> "dest/nixos_${VERSION}_${ARCH}.xml"
}

if [ "$1" = "all" ]; then
	combine "free"
	combine "unfree"
else
    combine "$1"
fi

gzip "dest/nixos_${VERSION}_${ARCH}.xml"
