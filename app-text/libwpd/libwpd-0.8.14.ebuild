# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libwpd/libwpd-0.8.14.ebuild,v 1.2 2008/08/25 09:51:16 remi Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="WordPerfect Document import/export library"
HOMEPAGE="http://libwpd.sf.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE="doc"
RESTRICT="test"

RDEPEND=">=dev-libs/glib-2
	>=gnome-extra/libgsf-1.6"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )"

src_compile() {
	econf $(use_with doc docs) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES CREDITS INSTALL README TODO
}
