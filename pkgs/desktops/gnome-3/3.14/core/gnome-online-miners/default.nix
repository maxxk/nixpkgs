{ stdenv, fetchurl, pkgconfig, glib, gnome3, libxml2
, libsoup, json_glib, gmp, openssl, makeWrapper }:

stdenv.mkDerivation rec {
  name = "gnome-online-miners-${gnome3.version}.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-online-miners/${gnome3.version}/${name}.tar.xz";
    sha256 = "6c6b48be2f89400ca16560c6fff67519229034ea78be867c9fbcb86c1d7cf784";
  };

  doCheck = true;

  buildInputs = [ pkgconfig glib gnome3.libgdata libxml2 libsoup gmp openssl
                  gnome3.grilo gnome3.libzapojit gnome3.grilo-plugins
                  gnome3.gnome_online_accounts makeWrapper gnome3.libmediaart
                  gnome3.tracker gnome3.gfbgraph json_glib gnome3.rest ];

  enableParallelBuilding = true;

  preFixup = ''
    for f in $out/libexec/*; do
      wrapProgram "$f" \
        --prefix GRL_PLUGIN_PATH : "${gnome3.grilo-plugins}/lib/grilo-0.2"
    done
  '';

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/GnomeOnlineMiners;
    description = "A set of crawlers that go through your online content and index them locally in Tracker";
    maintainers = with maintainers; [ lethalman ];
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
