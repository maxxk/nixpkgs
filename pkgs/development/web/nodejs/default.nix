{ stdenv, fetchurl, fetchpatch, python, utillinux,
  openssl_1_0_2, http-parser, zlib, libuv }:

let
  # Watch updated packages: https://github.com/nodejs/node/issues/2798
  version = "4.1.1";
  inherit (stdenv.lib) optional optionals maintainers licenses platforms;

in stdenv.mkDerivation {
  name = "nodejs-${version}";

  src = fetchurl {
    url = "https://nodejs.org/dist/v${version}/node-v${version}.tar.xz";
    sha256 = "f7ca9ceb0b7cc49b12f28a652c908a1f0ffbf34cec73ad0805fe717b14996bb9";
  };

  prePatch = ''
    sed -e 's|^#!/usr/bin/env python$|#!${python}/bin/python|g' -i configure
  '';

  # link error for -lgcc_s.10.5
  patchFlags = "-p0";
  patches = optional stdenv.isDarwin (fetchpatch {
    url = "https://svn.macports.org/repository/macports/trunk/dports/devel/iojs/files/patch-common.gypi.diff";
    sha256 = "0ibjwf01d95fbnh8jp76v9wll47p397m5igaa2vhcssh0r18mp3k";
    });

  configureFlags = [ "--shared-openssl" "--shared-http-parser" "--shared-zlib" "--shared-libuv" "--without-dtrace" ];

  # iojs and nodejs v4+ have --enable-static but no --disable-static.
  # Automatically adding --disable-static causes configure to fail, so don't add --disable-static.
  dontDisableStatic = true;

  buildInputs = [ python openssl_1_0_2 http-parser zlib libuv ]
    ++ (optional stdenv.isLinux utillinux);
  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  passthru.interpreterName = "nodejs";

  meta = {
    description = "Event-driven I/O framework for the V8 JavaScript engine";
    homepage = http://nodejs.org;
    license = licenses.mit;
    maintainers = [ maintainers.goibhniu maintainers.havvy ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
