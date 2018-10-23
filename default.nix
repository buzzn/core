{}:
let
  pkgs = import <nixpkgs> {};
  ruby = (pkgs.ruby_2_3.override { useRailsExpress = false; });
  stdenv = pkgs.stdenv;
  bundler = pkgs.bundler.override { inherit ruby; };
  bundix = pkgs.bundix.override { inherit bundler; };
  gems = pkgs.bundlerEnv {
    name = "hive";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
    groups = [ "default" "production" "development" "test" ];
  };
in stdenv.mkDerivation {
  name = "hive";
  buildInputs = [
    pkgs.wkhtmltopdf
    bundix
    gems
    gems.wrappedRuby
    gems.bundler
    pkgs.which
    pkgs.file
    pkgs.postgresql
  ];
  dontStrip = true;
  dontPatchELF = true;
  dontGzipMan = true;
}
