# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gvfs/gvfs-1.0.3.ebuild,v 1.1 2008/11/29 11:54:51 eva Exp $

EAPI="prefix"

inherit bash-completion gnome2 eutils flag-o-matic

DESCRIPTION="GNOME Virtual Filesystem Layer"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="archive avahi bluetooth cdda doc fuse gnome gphoto2 hal gnome-keyring samba"

RDEPEND=">=dev-libs/glib-2.17.6
		 >=sys-apps/dbus-1.0
		 >=net-libs/libsoup-2.23.91
		 dev-libs/libxml2
		 net-misc/openssh
		 archive? ( app-arch/libarchive )
		 avahi? ( >=net-dns/avahi-0.6 )
		 cdda?  (
					>=sys-apps/hal-0.5.10
					>=dev-libs/libcdio-0.78.2
				)
		 fuse? ( sys-fs/fuse )
		 gnome? ( >=gnome-base/gconf-2.0 )
		 hal? ( >=sys-apps/hal-0.5.10 )
		 bluetooth? (
			dev-libs/dbus-glib
			>=net-wireless/bluez-libs-3.12
			dev-libs/expat
			)
		 gphoto2? ( >=media-libs/libgphoto2-2.4 )
		 gnome-keyring? ( >=gnome-base/gnome-keyring-1.0 )
		 samba? ( >=net-fs/samba-3 )"
DEPEND="${RDEPEND}
		>=dev-util/intltool-0.40
		>=dev-util/pkgconfig-0.19
		doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	# CFLAGS needed for Solaris. Took it from here:
	# https://svn.sourceforge.net/svnroot/pkgbuild/spec-files-extra/trunk/SFEgnome-gvfs.spec
	[[ ${CHOST} == *-solaris* ]] && append-flags "-D_XPG4_2 -D__EXTENSIONS__"
	G2CONF="${G2CONF}
			--enable-http
			--disable-bash-completion
			$(use_enable archive)
			$(use_enable avahi)
			$(use_enable bluetooth obexftp)
			$(use_enable cdda)
			$(use_enable fuse)
			$(use_enable gnome gconf)
			$(use_enable gphoto2)
			$(use_enable hal)
			$(use_enable gnome-keyring keyring)
			$(use_enable samba)"

	if use cdda && built_with_use dev-libs/libcdio minimal; then
		ewarn
		ewarn "CDDA support in gvfs requires dev-libs/libcdio to be built"
		ewarn "without the minimal USE flag."
		die "Please re-emerge dev-libs/libcdio without the minimal USE flag"
	fi
}

src_unpack() {
	gnome2_src_unpack
	epatch "${FILESDIR}"/${PN}-0.2.3-interix.patch
	# There is no mkdtemp on Solaris libc. Using the same code as on Interix	
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i -e 's:mkdtemp:mktemp:g' daemon/gvfsbackendburn.c
	fi
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_header_stropts_h=no

	gnome2_src_compile
}

src_install() {
	gnome2_src_install
	use bash-completion && \
		dobashcompletion programs/gvfs-bash-completion.sh ${PN}
}

pkg_postinst() {
	gnome2_pkg_postinst
	use bash-completion && bash-completion_pkg_postinst
}
