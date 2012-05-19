# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libart_lgpl/libart_lgpl-2.3.21-r1.ebuild,v 1.12 2012/05/15 23:31:32 aballier Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools eutils gnome2

DESCRIPTION="a LGPL version of libart"
HOMEPAGE="http://www.levien.com/libart"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="virtual/pkgconfig"

# The provided tests are interactive only
RESTRICT="test"

DOCS="AUTHORS ChangeLog NEWS README"

# in prefix, einstall is broken for this package (misses --libdir)
USE_DESTDIR="yes"

pkg_setup() {
	G2CONF="${G2CONF} --disable-static"
}

src_prepare() {
	gnome2_src_prepare

	AT_NOELIBTOOLIZE=yes eautoreconf
}
