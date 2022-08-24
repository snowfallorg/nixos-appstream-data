#!/bin/sh
ARCH="x86_64_linux"

if [ "$1" != "free" -a "$1" != "unfree" -a "$1" != "all" ]; then
    echo "Usage: $0 [free|unfree|all]"
    exit 1
fi
set -e
rm -rf "dest"
mkdir -p "dest"
touch "dest/nixos_${ARCH}.xml"

combine() {
    cp -r "$1/icons" "dest/"
    find "$1/metadata" -type f -name "*.xml" | sort | while read file; do
        sed -e 's/<application>/<component type="desktop-application">/g' "$file" | sed -e 's/<\/application>/<\/component>/g' |
        sed -e 's/<component>/<component type="desktop-application">/g' | sed -n -e '/<component/,$p' |
        sed 's/^/  /' | sed -e '$a\' >> "dest/nixos_${ARCH}.xml"
    done
}

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<components version=\"0.14\" origin=\"nixos\">" > "dest/nixos_${ARCH}.xml"

if [ "$1" = "all" ]; then
	combine "free"
	combine "unfree"
else
    combine "$1"
fi

echo "</components>" >> "dest/nixos_${ARCH}.xml"

appstreamcli convert "dest/nixos_${ARCH}.xml" "dest/nixos_${ARCH}.yml"
gzip "dest/nixos_${ARCH}.xml"
gzip "dest/nixos_${ARCH}.yml"
