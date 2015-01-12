{ stdenv, fetchurl, pkgconfig, libxml2, gtk, intltool, libsoup, gconf
, pango, gdk_pixbuf, atk, tzdata, gnome3 }:

stdenv.mkDerivation rec {
  name = "libgweather-${gnome3.version}.2";

  src = fetchurl {
    url = "mirror://gnome/sources/libgweather/${gnome3.version}/${name}.tar.xz";
    sha256 = "aa0d03132fc6c446cf549df1d91e319e1abcc676f1d9f8bc1dc01f033dcff493";
  };

  makeFlags = "INTROSPECTION_GIRDIR=$(out)/share/gir-1.0/ INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0";

  configureFlags = [ "--with-zoneinfo-dir=${tzdata}/share/zoneinfo" ];
  propagatedBuildInputs = [ libxml2 gtk libsoup gconf pango gdk_pixbuf atk gnome3.geocode_glib ];
  nativeBuildInputs = [ pkgconfig intltool ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = [ maintainers.lethalman ];
  };
}
