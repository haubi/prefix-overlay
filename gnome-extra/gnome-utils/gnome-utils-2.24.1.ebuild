# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-utils/gnome-utils-2.24.1.ebuild,v 1.7 2009/03/15 21:41:06 maekke Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Utilities for the Gnome2 desktop"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="doc hal ipv6"

RDEPEND=">=dev-libs/glib-2.16.0
	>=x11-libs/gtk+-2.11.6
	>=gnome-base/gnome-desktop-2.9.91
	>=gnome-base/libgnome-2.13.2
	>=gnome-base/libgnomeui-2.13.7
	>=gnome-base/libglade-2.3
	>=gnome-base/libbonoboui-2.1
	>=gnome-base/gnome-vfs-2.8.4
	>=gnome-base/gnome-panel-2.13.4
	>=gnome-base/libgtop-2.12
	>=gnome-base/gconf-2
	sys-fs/e2fsprogs
	hal? ( >=sys-apps/hal-0.5 )
	x11-libs/libXext"

DEPEND="${RDEPEND}
	x11-proto/xextproto
	app-text/gnome-doc-utils
	app-text/scrollkeeper
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README THANKS"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable ipv6)
		$(use_enable hal)
		$(use_enable hal gfloppy)
		--enable-console-helper=no
		--disable-schemas-install
		--disable-scrollkeeper"
}
