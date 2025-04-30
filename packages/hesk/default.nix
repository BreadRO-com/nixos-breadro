{ lib
, stdenvNoCC
, fetchFromGitHub
, stateDir ? null
, removeInstall ? true
, langPack ? null
}:

let
    pname = "hesk";
    version = "0-unstable-2025-04-30";
in

stdenvNoCC.mkDerivation {
  pname = pname;
  version = version;

  src = fetchFromGitHub {
    owner = "BreadRO-com";
    repo = pname;
    rev = "c6f7423d7c40a22c5490eae4cb96ce4ac7d29a66";
    hash = "sha256-K98a+D/c3+xKNuDr6d8FkNL8MeMOxGnXGfeXj1ZKMck=";
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
