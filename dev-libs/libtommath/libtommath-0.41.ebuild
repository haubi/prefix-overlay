# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libtommath/libtommath-0.41.ebuild,v 1.3 2009/07/28 21:53:31 vostorga Exp $

inherit eutils multilib

DESCRIPTION="highly optimized and portable routines for integer based number theoretic applications"
HOMEPAGE="http://www.libtom.org/"
SRC_URI="http://www.libtom.org/files/ltm-${PV}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-devel/libtool"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-LDFLAGS.patch
	epatch "${FILESDIR}"/${P}-CC.patch

	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's/libtool/glibtool/g' makefile.shared
	use prefix && sed -i \
		-e 's:install -d -g $(GROUP) -o $(USER):install -d:g' \
		-e 's:install -g $(GROUP) -o $(USER):install:g' \
		makefile.shared
}

src_compile() {
	emake CC=$(tc-getCC) -f makefile.shared IGNORE_SPEED=1 LIBPATH="${EPREFIX}/usr/$(get_libdir)" || die "emake failed"
}

src_install() {
	make -f makefile.shared install DESTDIR="${D}" LIBPATH="${EPREFIX}/usr/$(get_libdir)" INCPATH="${EPREFIX}/usr/include" || die
	dodoc changes.txt *.pdf
	docinto demo ; dodoc demo/*.c
}
