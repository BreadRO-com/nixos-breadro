{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
    pname = "hesk";
    version = "3.5.3";
in

stdenvNoCC.mkDerivation {
  pname = pname;
  version = version;

  src = fetchFromGitHub {
    owner = "BreadRO-com";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-WCcRbMlgsOmgoa+u9lg0N6eH4XlFUKm24QgpQ0m2FSI=";
  };

  # There's nothing to build.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hesk
    cp -r . $out/share/hesk

    runHook postInstall
  '';

  meta = {
    description = "A surprisingly simple, user-friendly and FREE help desk software with integrated knowledgebase.";
    homepage = "https://www.hesk.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
