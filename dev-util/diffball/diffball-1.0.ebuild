# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/diffball/diffball-1.0.ebuild,v 1.7 2007/08/13 20:48:59 dertobi123 Exp $

EAPI="prefix"

IUSE="debug"

DESCRIPTION="Delta compression suite for using/generating binary patches"
HOMEPAGE="http://developer.berlios.de/projects/diffball/"
SRC_URI="http://download.berlios.de/diffball/${P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"

DEPEND=">=sys-libs/zlib-1.1.4
	>=app-arch/bzip2-1.0.2"
RESTRICT="strip"

src_compile() {
	econf $(use_enable debug asserts)
	emake || die "emake failed"
}

src_install() {
	cd ${S}
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog README TODO
}
