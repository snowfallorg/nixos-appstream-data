# Appstream data for NixOS

```shell
nix build .#appstream-data
```

or for unfree metadata

```shell
nix build .#appstream-data-unfree
```

or for both free and unfree combined

```shell
nix build .#appstream-data-all
```

# Licenses

All metadata and icons fall under the licenses specified in their respective metainfo files under the `metadata_license` tag.

The rest of the code in this repository is licensed under the [MIT license](./LICENSE).
