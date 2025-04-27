{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
    lang = "zh_cmn_hans";
    pname = "hesk-${lang}";
    version = "3.5";
in

stdenvNoCC.mkDerivation {
  pname = pname;
  version = version;

  src = fetchFromGitHub {
    owner = "BreadRO-com";
    repo = pname;
    rev = "faea26dfe6bfad2b668e14e0bd42c5268f4131b1";
    hash = "sha256-A7Rpbinfr3LYekQTQQW7KXfWPy50skQkkbXOjf5pOto=";
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
