{ pkgs ? import <nixpkgs> { } }:

let
  dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;

  patchelf = libPath:
    if pkgs.stdenv.isDarwin
    then ""
    else ''
      chmod u+w $CABAL_FMT
      patchelf --interpreter ${dynamic-linker} --set-rpath ${libPath} $CABAL_FMT
      chmod u-w $CABAL_FMT
    '';
in
pkgs.stdenv.mkDerivation rec {
  pname = "cabal-fmt";

  version = "test";

  buildInputs = [ pkgs.gmp ];

  libPath = pkgs.lib.makeLibraryPath buildInputs;

  src =
    if pkgs.stdenv.isDarwin
    then
      pkgs.fetchzip
        {
          url = "https://github.com/justinwoo/cabal-fmt/releases/download/test/macOS-latest.tar.gz";
          sha256 = "vfX9GcZZVJMkzDgSzAeAlWRRtKR46Uup4ohPlSVymP0=";
        }
    else
      pkgs.fetchzip {
        url = "https://github.com/justinwoo/cabal-fmt/releases/download/test/ubuntu-latest.tar.gz";
        sha256 = "DWQG7DLWHrS7r/yqgv927U1yXYYvYrjs/0swiyGIL44=";
      };

  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    CABAL_FMT=$out/bin/cabal-fmt

    install -D -m555 -T cabal-fmt $CABAL_FMT
    ${patchelf libPath}

    mkdir -p $out/etc/bash_completion.d/
    $CABAL_FMT --bash-completion-script $CABAL_FMT > $out/etc/bash_completion.d/cabal-fmt-completion.bash
  '';
}
