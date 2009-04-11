# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libbonoboui/libbonoboui-2.20.0.ebuild,v 1.10 2009/03/08 01:39:47 eva Exp $

inherit eutils virtualx gnome2

DESCRIPTION="User Interface part of libbonobo"
HOMEPAGE="http://developer.gnome.org/arch/gnome/componentmodel/bonobo.html"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="doc"

# GTK+ dep due to bug #126565
RDEPEND=">=gnome-base/libgnomecanvas-1.116
	>=gnome-base/libbonobo-2.13
	>=gnome-base/libgnome-2.13.7
	>=dev-libs/libxml2-2.4.20
	>=gnome-base/gconf-2
	>=x11-libs/gtk+-2.8.12
	>=dev-libs/glib-2.6.0
	>=gnome-base/gnome-vfs-2.8
	>=gnome-base/libglade-1.99.11
	>=dev-libs/popt-1.5"

DEPEND="${RDEPEND}
	x11-apps/xrdb
	sys-devel/gettext
	>=dev-util/pkgconfig-0.20
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_compile() {
	addpredict "/root/.gnome2_private"

	gnome2_src_compile
}

src_test() {
	addwrite "/root/.gnome2_private"
	Xmake check || die
}
