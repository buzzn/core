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
#    pkgs.postgresql
    pkgs.mysql
    pkgs.heroku
    pkgs.inotify-tools
  ];
  dontStrip = true;
  dontPatchELF = true;
  dontGzipMan = true;

  SECRET_KEY_BASE = "7dce4c5b93f9878c8976473cffeca3cc2630860afab0c25cdff130170728a4533060e41be95db4fbb433f41812b9d642a49ac0c14113287d12743e52ad7c83e0";
  AWS_BUCKET="buzzn-core-staging";
  AWS_ACCESS_KEY="AKIAIN5EJC45OVBS567Q";
  AWS_SECRET_KEY="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";
  AWS_REGION="eu-west-1";
  ASSET_HOST = "https://files.de.buzzn.net";
  HOSTNAME="https://de.buzzn.net";
  DEFAULT_ACCOUNT_PASSWORD = "xx";
  MAIL_BACKEND="stdout";
}
