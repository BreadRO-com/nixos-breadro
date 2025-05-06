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
    rev = "dbd95febb8786f5024f9fe604eebb7501f7a8e77";
    hash = "sha256-0KqZkis6Z3NOyiIttvf25KvICKwEkSOkkcuCGkd33iw=";
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
