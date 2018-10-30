{ stdenv, fetchurl, makeWrapper, sbcl, sqlite, freetds, libzip, curl, git, cacert, openssl }:
stdenv.mkDerivation rec {
  pname = "pgloader";
  version = "3.5.2";
  name = "${pname}-${version}";

  src = fetchurl {
    # not possible due to sandbox
    # url = "https://github.com/dimitri/pgloader/archive/v${version}.tar.gz";
    # sha256 = "1bk5avknz6sj544zbi1ir9qhv4lxshly9lzy8dndkq5mnqfsj1qs";

    url = "https://github.com/dimitri/pgloader/releases/download/v3.5.2/pgloader-bundle-3.5.2.tgz";
    sha256 = "06fvhpbr8js0pkkscm9iaarcq4910di50qmhq9fz2hzrdajwsf7a";
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
    install -Dm755 bin/pgloader "$out/bin/pgloader"
    wrapProgram $out/bin/pgloader --prefix LD_LIBRARY_PATH : "${LD_LIBRARY_PATH}"
  '';

}

