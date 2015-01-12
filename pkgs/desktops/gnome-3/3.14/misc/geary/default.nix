{ stdenv, fetchurl, intltool, pkgconfig, gtk3, vala
, makeWrapper, gdk_pixbuf, cmake, desktop_file_utils
, libnotify, libcanberra, libsecret, gmime
, libpthreadstubs, hicolor_icon_theme
, gnome3, librsvg, gnome_doc_utils, webkitgtk }:

let
  majorVersion = "0.8";
in
stdenv.mkDerivation rec {
  name = "geary-${majorVersion}.3";

  src = fetchurl {
    url = "mirror://gnome/sources/geary/${majorVersion}/${name}.tar.xz";
    sha256 = "87db09b1e4fb8e18c8341561a100003a3d05f954dc6fadc076b658c6699c784e";
  };

  propagatedUserEnvPkgs = [ gnome3.gnome_themes_standard ];

  buildInputs = [ intltool pkgconfig gtk3 makeWrapper cmake desktop_file_utils gnome_doc_utils
                  vala webkitgtk libnotify libcanberra gnome3.libgee libsecret gmime
                  libpthreadstubs gnome3.gsettings_desktop_schemas hicolor_icon_theme
                  gdk_pixbuf librsvg gnome3.adwaita-icon-theme gnome3.adwaita-icon-theme ];

  preConfigure = ''
    substituteInPlace src/CMakeLists.txt --replace '`pkg-config --variable=girdir gobject-introspection-1.0`' '${webkitgtk}/share/gir-1.0'
  '';

  postInstall = ''
    mkdir -p $out/share/gsettings-schemas/${name}/
    mv $out/share/glib-2.0 $out/share/gsettings-schemas/${name}
  '';

  preFixup = ''
    wrapProgram "$out/bin/geary" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:${gnome3.gnome_themes_standard}/share:$out/share:$GSETTINGS_SCHEMAS_PATH"
  '';

  enableParallelBuilding = true;

  patches = [ ./disable_valadoc.patch ];
  patchFlags = "-p0";

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Geary;
    description = "Mail client for GNOME 3";
    maintainers = with maintainers; [ lethalman ];
    license = licenses.lgpl2;
    platforms = platforms.linux;
  };
}
