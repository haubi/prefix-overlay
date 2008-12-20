# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libbonobo/libbonobo-2.24.0.ebuild,v 1.6 2008/12/17 14:32:55 ranger Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="GNOME CORBA framework"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2.1 GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.8
	>=gnome-base/orbit-2.14.0
	>=dev-libs/libxml2-2.4.20
	>=sys-apps/dbus-1.0.0
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/popt-1.5
	!gnome-base/bonobo-activation"
DEPEND="${RDEPEND}
	sys-devel/flex
	x11-apps/xrdb
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable debug bonobo-activation-debug)"
}

src_unpack() {
	gnome2_src_unpack

	sed -i -e '/DISABLE_DEPRECATED/d' \
		"${S}/activation-server/Makefile.am" "${S}/activation-server/Makefile.in" \
		"${S}/bonobo/Makefile.am" "${S}/bonobo/Makefile.in" \
		"${S}/bonobo-activation/Makefile.am" "${S}/bonobo-activation/Makefile.in"

	sed -i -e 's:-DG_DISABLE_DEPRECATED ::g' \
		"${S}/tests/test-activation/Makefile.am" "${S}/tests/test-activation/Makefile.in"
}
