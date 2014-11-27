{ stdenv, fetchurl, intltool, wirelesstools, pkgconfig, dbus_glib, xz
, udev, libnl, libuuid, polkit, gnutls, ppp, dhcp, dhcpcd, iptables
, libgcrypt, dnsmasq, avahi, bind, perl, bluez5, substituteAll, iputils
, gobjectIntrospection, modemmanager, openresolv, readline, libndp }:

stdenv.mkDerivation rec {
  name = "network-manager-${version}";
  version = "0.9.10.0";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager/0.9/NetworkManager-${version}.tar.xz";
    sha256 = "66a88346bb04d4f402540281181340313b2ec433e75aa9d9ea13f31697f9487e";
  };

  # Right now we hardcode quite a few paths at build time. Probably we should
  # patch networkmanager to allow passing these path in config file. This will
  # remove unneeded build-time dependencies.
  configureFlags = [
    "--with-distro=exherbo"
    "--with-dhclient=${dhcp}/sbin/dhclient"
    # Upstream prefers dhclient, so don't add dhcpcd to the closure
    #"--with-dhcpcd=${dhcpcd}/sbin/dhcpcd"
    "--with-dhcpcd=no"
    "--with-iptables=${iptables}/sbin/iptables"
    "--with-pppd=${ppp}/sbin/pppd"
    "--with-udev-dir=\${out}/lib/udev"
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    "--sysconfdir=/etc" "--localstatedir=/var"
    "--with-dbus-sys-dir=\${out}/etc/dbus-1/system.d"
    "--with-crypto=gnutls" "--disable-more-warnings"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    "--with-session-tracking=systemd"
    "--with-modem-manager-1"
  ];

  buildInputs = [ wirelesstools udev libnl libuuid polkit ppp xz bluez5
                  gobjectIntrospection modemmanager libndp readline ];

  propagatedBuildInputs = [ dbus_glib gnutls libgcrypt ];

  nativeBuildInputs = [ intltool pkgconfig ];

  patches =
    [ ( substituteAll {
        src = ./nixos-purity.patch;
        inherit avahi dnsmasq bind iputils;
        glibc = stdenv.gcc.libc;
      })
      ./unmanage_virtual.patch
    ];

  preInstall =
    ''
      installFlagsArray=( "sysconfdir=$out/etc" "localstatedir=$out/var" )
    '';

  postInstall =
    ''
      mkdir -p $out/lib/NetworkManager

      # FIXME: Workaround until NixOS' dbus+systemd supports at_console policy
      substituteInPlace $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf --replace 'at_console="true"' 'group="networkmanager"'

      # rename to network-manager to be in style
      mv $out/etc/systemd/system/NetworkManager.service $out/etc/systemd/system/network-manager.service 
      echo "Alias=NetworkManager.service" >> $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service

      # systemd in NixOS doesn't use `systemctl enable`, so we need to establish
      # aliases ourselves.
      ln -s $out/etc/systemd/system/NetworkManager-dispatcher.service $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
      ln -s $out/etc/systemd/system/network-manager.service $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service

      # fix readline in libtool file, avoid putting it in propagated build inputs
      for lib in $out/lib/*.la; do
        substituteInPlace $lib --replace "-lreadline" "-L${readline}/lib -lreadline"
      done
    '';

  meta = with stdenv.lib; {
    homepage = http://projects.gnome.org/NetworkManager/;
    description = "Network configuration and management tool";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ phreedom urkud rickynils iElectric lethalman ];
    platforms = platforms.linux;
  };
}
