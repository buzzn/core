{ stdenv, fetchurl, makeWrapper, sbcl, sqlite, freetds, libzip, curl, git, cacert, openssl }:
stdenv.mkDerivation rec {
  pname = "pgloader";
  version = "3.5.2";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/dimitri/pgloader/archive/v${version}.tar.gz";
    sha256 = "1bk5avknz6sj544zbi1ir9qhv4lxshly9lzy8dndkq5mnqfsj1qs";
  };

  buildInputs = [ sbcl cacert sqlite freetds libzip curl git openssl makeWrapper ];

  LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ sqlite libzip curl git openssl freetds ];

  buildPhase = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR
    make pgloader
  '';

  dontStrip = true;
  enableParallelBuilding = false;

  installPhase = ''
    install -Dm755 build/bin/pgloader "$out/bin/pgloader"
    wrapProgram $out/bin/pgloader --prefix LD_LIBRARY_PATH : "${LD_LIBRARY_PATH}"
  '';

}

