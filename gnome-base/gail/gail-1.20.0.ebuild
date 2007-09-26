# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gail/gail-1.20.0.ebuild,v 1.1 2007/09/25 19:16:06 dang Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Accessibility support for Gtk+ and libgnomecanvas"
HOMEPAGE="http://developer.gnome.org/projects/gap/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc"

RDEPEND=">=dev-libs/atk-1.13.0
	>=x11-libs/gtk+-2.9.4
	>=gnome-base/libgnomecanvas-2
	x11-libs/libX11"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"
