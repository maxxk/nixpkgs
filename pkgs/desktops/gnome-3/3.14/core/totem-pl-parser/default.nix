{ stdenv, fetchurl, pkgconfig, file, intltool, gmime, libxml2, libsoup }:

stdenv.mkDerivation rec {
  name = "totem-pl-parser-3.10.3";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/3.10/${name}.tar.xz";
    sha256 = "14512c76c7f375d8bb9e9a220afbac20be2d2eb82abee9a8986d264079a0c72f";
  };

  buildInputs = [ pkgconfig file intltool gmime libxml2 libsoup ];

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Videos;
    description = "Simple GObject-based library to parse and save a host of playlist formats";
    maintainers = with maintainers; [ lethalman ];
    license = licenses.lgpl2;
    platforms = platforms.linux;
  };
}
