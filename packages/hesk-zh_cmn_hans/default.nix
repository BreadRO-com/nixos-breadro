{ lib
, stdenvNoCC
, fetchzip
}:

let
    lang = "zh_cmn_hans";
    pname = "hesk-${lang}";
    version = "3.5";
in

stdenvNoCC.mkDerivation {
  pname = pname;
  version = version;

  src = fetchzip {
    url = "https://www.hesk.com/language/download.php?tag=${lang}&version=${version}";
    extension = "zip";
    stripRoot = false;
    hash = "sha256-9WHiqsfpcITkEW+PDEFqQxQBUt4Yny7JU4Eo8yKL4rM=";
  };

  # There's nothing to build.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hesk/language
    cp -r . $out/share/hesk/language

    runHook postInstall
  '';

  meta = {
    description = "${lang} language pack for HESK.";
    homepage = "https://www.hesk.com/language/info.php?tag=${lang}";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
