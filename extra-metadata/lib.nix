{ pkgs }:
let
  inherit (pkgs) lib;

  licenseToSpdx =
    license:
    if license == null then
      "LicenseRef-proprietary"
    else if license ? spdxId then
      license.spdxId
    else if license ? shortName then
      if (license.shortName == "unfree" || license.shortName == "unfreeRedistributable") then
        "LicenseRef-proprietary"
      else
        "LicenseRef-${license.shortName}"
    else
      "LicenseRef-proprietary";
in
{
  addAppstreamMetainfo =
    pkg:
    {
      src ? null,
      id ? throw "id is required",
      name ?
        let
          s = pkg.pname or (builtins.parseDrvName pkg.name).name;
        in
        lib.toUpper (lib.substring 0 1 s) + lib.substring 1 (-1) s,
      summary ? pkg.meta.description or (if src == null then throw "summary is required" else null),
      developer ? null,
      developerId ? null,
      homepage ? pkg.meta.homepage or null,
      launchable ? "${id}.desktop",
      description ? (
        if pkg.meta ? longDescription then
          [ pkg.meta.longDescription ]
        else if src == null then
          throw "description is required"
        else
          [ ]
      ),
      categories ? [ ],
      license ? licenseToSpdx (pkg.meta.license or null),
      metadataLicense ? "CC0-1.0",
      screenshots ? [ ],
      extraXml ? "",
    }:
    let
      developerXml =
        if developer != null then
          (
            if developerId != null then
              ''<developer id="${developerId}"><name>${developer}</name></developer>''
            else
              "<developer><name>${developer}</name></developer>"
          )
        else
          "";

      homepageXml = if homepage != null then ''<url type="homepage">${homepage}</url>'' else "";

      descriptionXml =
        if description != [ ] then
          "<description>${
            lib.concatStringsSep "" (map (p: "<p>${lib.replaceStrings [ "\n" ] [ " " ] p}</p>") description)
          }</description>"
        else
          "";

      categoriesXml =
        if categories != [ ] then
          "<categories>${
            lib.concatStringsSep "" (map (c: "<category>${c}</category>") categories)
          }</categories>"
        else
          "";

      screenshotsXml =
        if screenshots != [ ] then
          "<screenshots>${
            lib.concatStringsSep "" (
              map (
                s:
                if s ? caption then
                  ''<screenshot><image type="source">${s.url}</image><caption>${s.caption}</caption></screenshot>''
                else
                  ''<screenshot><image type="source">${s.url}</image></screenshot>''
              ) screenshots
            )
          }</screenshots>"
        else
          "";

      metainfoContent = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <component type="desktop-application">
          <id>${id}</id>
          <name>${name}</name>
          ${developerXml}
          <summary>${summary}</summary>
          <metadata_license>${metadataLicense}</metadata_license>
          <project_license>${license}</project_license>
          ${homepageXml}
          <launchable type="desktop-id">${launchable}</launchable>
          ${descriptionXml}
          ${screenshotsXml}
          ${categoriesXml}
          ${extraXml}
        </component>
      '';

      metainfoFilename = "${id}.metainfo.xml";

      metainfoFile =
        if builtins.isPath src then
          src
        else if src != null && builtins.isAttrs src && src ? drvPath then
          src
        else
          builtins.toFile metainfoFilename metainfoContent;

    in
    pkg.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        mkdir -p $out/share/metainfo
        ${
          if src != null then
            ''
              sed '/<releases>/,/<\/releases>/d' ${metainfoFile} > $out/share/metainfo/${metainfoFilename}
            ''
          else
            ''
              cp ${metainfoFile} $out/share/metainfo/${metainfoFilename}
            ''
        }
      '';
    });
}
