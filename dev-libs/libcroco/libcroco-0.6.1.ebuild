# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.1.ebuild,v 1.14 2008/01/09 13:17:54 welp Exp $

EAPI="prefix"

inherit gnome2 autotools

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://www.freespiders.org/projects/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~sparc-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2
	>=dev-libs/libxml2-2.4.23"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"

src_unpack() {
	gnome2_src_unpack

	# added gtk-doc.m4 to FILESDIR ro avoid a dependency on gtk-doc, and
	# still be able to bootstrap this.
	AT_M4DIR="${FILESDIR}/m4" eautoreconf # need new libtool for interix
}
