# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/optipng/optipng-0.6.2.ebuild,v 1.1 2008/11/11 15:31:09 nyhm Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="Compress PNG files without affecting image quality"
HOMEPAGE="http://optipng.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "/^C/s: -O2.*: ${CFLAGS} -Wall:" \
		-e "/^LD/s: -s$: ${LDFLAGS}:" \
		src/scripts/gcc.mak \
		lib/libpng/scripts/makefile.gcc \
		lib/pngxtern/scripts/gcc.mak \
		|| die "sed failed"
}

src_compile() {
	emake CC="$(tc-getCC)" -C src -f scripts/gcc.mak || die "emake failed"
}

src_install() {
	dobin src/optipng || die "dobin failed"
	dodoc README.txt doc/*.txt
	dohtml doc/*.html
	doman man/optipng.1
}
