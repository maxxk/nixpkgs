{ stdenv, fetchurl, fetchgit, vala, intltool, libgit2, pkgconfig, gtk3, glib
, json_glib, webkitgtk,  makeWrapper, libpeas, bash, gobjectIntrospection
, gnome3, gtkspell3, shared_mime_info, libgee, libgit2-glib, librsvg }:

# TODO: icons and theme still does not work
# use packaged gnome3.adwaita-icon-theme 

let
  majorVersion = "3.14";
in
stdenv.mkDerivation rec {
  name = "gitg-${majorVersion}.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gitg/${majorVersion}/${name}.tar.xz";
    sha256 = "8e485b35d918fddc255c3bf5d5c139d0a8b684bd922a8913153b1b7781357057";
  };

  preCheck = ''
    substituteInPlace tests/libgitg/test-commit.c --replace "/bin/bash" "${bash}/bin/bash"
  '';
  doCheck = true;

  makeFlags = "INTROSPECTION_GIRDIR=$(out)/share/gir-1.0/ INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0";

  propagatedUserEnvPkgs = [ shared_mime_info
                            gnome3.gnome_themes_standard ];

  buildInputs = [ vala intltool libgit2 pkgconfig gtk3 glib json_glib webkitgtk libgee libpeas
                  libgit2-glib gtkspell3 gnome3.gsettings_desktop_schemas gnome3.gtksourceview librsvg
                  gobjectIntrospection makeWrapper gnome3.adwaita-icon-theme ];

  preFixup = ''
    wrapProgram "$out/bin/gitg" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:${gtk3}/share:${gnome3.gnome_themes_standard}/share:$out/share:$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/action/show/Apps/Gitg;
    description = "GNOME GUI client to view git repositories";
    maintainers = with maintainers; [ iElectric ];
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
