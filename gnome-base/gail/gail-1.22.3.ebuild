# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gail/gail-1.22.3.ebuild,v 1.8 2008/11/13 19:00:28 ranger Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Accessibility support for Gtk+ and libgnomecanvas"
HOMEPAGE="http://developer.gnome.org/projects/gap/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/atk-1.13.0
	>=x11-libs/gtk+-2.9.4
	x11-libs/libX11"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	sys-devel/gettext
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"
