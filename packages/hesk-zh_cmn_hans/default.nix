{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
    lang = "zh_cmn_hans";
    pname = "hesk-${lang}";
    version = "0-unstable-2025-04-30";
in

stdenvNoCC.mkDerivation {
  pname = pname;
  version = version;

  src = fetchFromGitHub {
    owner = "BreadRO-com";
    repo = pname;
    rev = "ee2d00e842d8cffb625cdd5bc8f627e4d9ae5aaf";
    hash = "sha256-35PMsC6vhFl2BHGUYoyw4xf22QKqtXuqAvCTtfLjOaA=";
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
