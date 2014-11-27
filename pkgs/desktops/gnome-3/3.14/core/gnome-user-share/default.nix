{ stdenv, intltool, fetchurl, apacheHttpd_2_2, nautilus
, pkgconfig, gtk3, glib, hicolor_icon_theme, libxml2, gnused
, bash, makeWrapper, itstool, libnotify, libtool, mod_dnssd
, gnome3, librsvg, gdk_pixbuf, file, libcanberra_gtk3 }:

stdenv.mkDerivation rec {
  name = "gnome-user-share-${gnome3.version}.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-user-share/${gnome3.version}/${name}.tar.xz";
    sha256 = "cd69e7d2a0131a6d542db4365b0f14e88fffb82fd2ce7d1f7d4a5190ee6efdb8";
  };

  doCheck = true;

  NIX_CFLAGS_COMPILE = "-I${gnome3.glib}/include/gio-unix-2.0";

  preConfigure = ''
    sed -e 's,^LoadModule dnssd_module.\+,LoadModule dnssd_module ${mod_dnssd}/modules/mod_dnssd.so,' -i data/dav_user_2.2.conf 
  '';

  configureFlags = [ "--with-httpd=${apacheHttpd_2_2}/bin/httpd"
                     "--with-modules-path=${apacheHttpd_2_2}/modules"
                     "--disable-bluetooth"
                     "--with-nautilusdir=$(out)/lib/nautilus/extensions-3.0" ];

  buildInputs = [ pkgconfig gtk3 glib intltool itstool libxml2 libtool
                  makeWrapper file gdk_pixbuf gnome3.adwaita-icon-theme librsvg
                  hicolor_icon_theme gnome3.adwaita-icon-theme
                  nautilus libnotify libcanberra_gtk3 ];

  postInstall = ''
    mkdir -p $out/share/gsettings-schemas/$name
    mv $out/share/glib-2.0 $out/share/gsettings-schemas/$name
    ${glib}/bin/glib-compile-schemas $out/share/gsettings-schemas/$name/glib-2.0/schemas
  '';

  preFixup = ''
    wrapProgram "$out/libexec/gnome-user-share" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "$out/share:$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with stdenv.lib; {
    homepage = https://help.gnome.org/users/gnome-user-share/3.8;
    description = "Service that exports the contents of the Public folder in your home directory on the local network";
    maintainers = with maintainers; [ lethalman ];
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
