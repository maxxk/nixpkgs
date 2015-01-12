{ stdenv, fetchurl, intltool, gtk3, gnome3, librsvg, pkgconfig, pango, atk, gtk2, gdk_pixbuf }:

stdenv.mkDerivation rec {
  name = "gnome-themes-standard-${gnome3.version}.2.3";
  src = fetchurl {
    url = "mirror://gnome/sources/gnome-themes-standard/${gnome3.version}/${name}.tar.xz";
    sha256 = "d82a1cf90be3397deadea46d3ba396a46943c7e141ebc70cf833956b5794e479";
  };
  
  buildInputs = [ intltool gtk3 librsvg pkgconfig pango atk gtk2 gdk_pixbuf ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = [ maintainers.lethalman ];
  };
}
