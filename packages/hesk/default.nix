{ lib
, stdenvNoCC
, fetchFromGitHub
, stateDir ? null
, removeInstall ? true
, langPack ? null
}:

let
    pname = "hesk";
    version = "0-unstable-2025-05-06";
in

stdenvNoCC.mkDerivation {
  pname = pname;
  version = version;

  src = fetchFromGitHub {
    owner = "BreadRO-com";
    repo = pname;
    rev = "42c0122eb5ae420f23c2b26b52a5e130a1ea9d16";
    hash = "sha256-etmeCZFFeebk/nJUKodM0mXIeQg8gOHnE7dpmlYzN9o=";
  };

  # There's nothing to build.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hesk
    cp -r . $out/share/hesk

  '' + lib.optionalString (stateDir != null) ''
    for i in attachments cache hesk_settings.inc.php; do
      rm -rf $out/share/hesk/$i
      ln -s ${stateDir}/$i $out/share/hesk/$i
    done
  '' + lib.optionalString removeInstall ''
    rm -rf $out/share/hesk/install
  '' + ''
  '' + lib.optionalString (langPack != null) ''
    cp -r ${langPack}/share/hesk/language/* $out/share/hesk/language/
  '' + ''

    runHook postInstall
  '';

  meta = {
    description = "A surprisingly simple, user-friendly and FREE help desk software with integrated knowledgebase.";
    homepage = "https://www.hesk.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
