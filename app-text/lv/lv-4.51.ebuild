# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/lv/lv-4.51.ebuild,v 1.13 2008/03/21 11:29:02 opfer Exp $

EAPI="prefix"

MY_P=${PN}${PV//./}
DESCRIPTION="Powerful Multilingual File Viewer"
HOMEPAGE="http://www.ff.iij4u.or.jp/~nrt/lv/"
SRC_URI="http://www.ff.iij4u.or.jp/~nrt/freeware/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-libs/ncurses"

S=${WORKDIR}/${MY_P}/build

src_compile() {
	LIBS=-lncurses ../src/configure \
		--host=${HOST} \
		--prefix="${EPREFIX}"/usr \
		--mandir="${EPREFIX}"/usr/share/man || die
	emake || die
}

src_install() {
	dodir /usr/{bin,lib,share/man/man1}
	einstall || die

	dodoc ../README
}
