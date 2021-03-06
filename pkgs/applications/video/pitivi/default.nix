{ stdenv, fetchurl, pkgconfig, intltool, itstool, makeWrapper
, python3Packages, gst, clutter-gtk, hicolor_icon_theme
, gobjectIntrospection, librsvg, gnome3, libnotify
}:

let
  version = "0.94";
in stdenv.mkDerivation rec {
  name = "pitivi-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pitivi/${version}/${name}.tar.xz";
    sha256 = "1v7s0qsibwykkmknspjhpdrj80s987pvbl01kh34k4aspi1hcapm";
  };

  meta = with stdenv.lib; {
    description = "Non-Linear video editor utilizing the power of GStreamer";
    homepage    = "http://pitivi.org/";
    longDescription = ''
      Pitivi is a video editor built upon the GStreamer Editing Services.
      It aims to be an intuitive and flexible application
      that can appeal to newbies and professionals alike.
    '';
    license     = licenses.lgpl21Plus;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ iyzsong ];
  };

  nativeBuildInputs = [ pkgconfig intltool itstool makeWrapper ];

  buildInputs = [
    gobjectIntrospection clutter-gtk librsvg gnome3.gnome_desktop
    gnome3.defaultIconTheme
    gnome3.gsettings_desktop_schemas libnotify
  ] ++ (with gst; [
    gstreamer gst-editing-services
    gst-plugins-base gst-plugins-good
    gst-plugins-bad gst-plugins-ugly gst-libav
  ]) ++ (with python3Packages; [
    python pygobject3 gst-python pyxdg numpy pycairo sqlite3
  ]);

  preFixup = ''
    wrapProgram "$out/bin/pitivi" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$out/share:$GSETTINGS_SCHEMAS_PATH"
  '';
}
