{ stdenv, fetchurl, pkgconfig, atk, cairo, glib, gtk3, pango
, libxml2Python, perl, intltool, gettext, gnome3 }:

stdenv.mkDerivation rec {
  name = "gtksourceview-${version}";
  version = "${gnome3.version}.3";

  src = fetchurl {
    url = "mirror://gnome/sources/gtksourceview/${gnome3.version}/gtksourceview-${version}.tar.xz";
    sha256 = "7bbe8b603ed7346669911fa074fe69388a4c89c1b15317befc3aa212b3d01a7b";
  };

  buildInputs = [ pkgconfig atk cairo glib gtk3 pango
                  libxml2Python perl intltool gettext ];

  preBuild = ''
    substituteInPlace gtksourceview/gtksourceview-utils.c --replace "@NIX_SHARE_PATH@" "$out/share"
  ''; 

  patches = [ ./nix_share_path.patch ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = [ maintainers.lethalman ];
  };
}
