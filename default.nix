{}:
let
  pkgs = import <nixpkgs> {};
  ruby = (pkgs.ruby_2_3.override { useRailsExpress = false; });
  stdenv = pkgs.stdenv;
  bundler = pkgs.bundler.override { inherit ruby; };
  bundix = pkgs.bundix.override { inherit bundler; };
  pgloader = pkgs.callPackage ./pgloader.nix {};
  wkhtmltopdf = pkgs.callPackage ./wkhtmltopdf/default.nix { overrideDerivation = pkgs.lib.overrideDerivation; };
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
    wkhtmltopdf
    bundix
    # bundler # enable for native bundle
    gems
    gems.wrappedRuby
    gems.bundler
    pkgs.which
    pkgs.file
    pkgs.postgresql
    pkgs.mysql
    pkgs.heroku
    pkgs.inotify-tools
  ];
  dontStrip = true;
  dontPatchELF = true;
  dontGzipMan = true;
}
