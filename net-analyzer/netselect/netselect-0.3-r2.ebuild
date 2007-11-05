# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/netselect/netselect-0.3-r2.ebuild,v 1.5 2007/11/02 21:32:08 pylon Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Ultrafast implementation of ping."
HOMEPAGE="http://alumnit.ca/~apenwarr/netselect/index.html"
SRC_URI="http://alumnit.ca/~apenwarr/netselect/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-macos"
IUSE=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-bsd.patch"
}

src_compile() {
	append-ldflags $(bindnow-flags)

	sed -i \
		-e "s:PREFIX =.*:PREFIX = ${ED}usr:" \
		-e "s:CFLAGS =.*:CFLAGS = -Wall -I. -g ${CFLAGS}:" \
		-e "s:LDFLAGS =.*:LDFLAGS = -g ${LDFLAGS}:" \
		-e '23,27d' \
		-e '34d' \
		Makefile \
		|| die "sed Makefile failed"

	emake CC=$(tc-getCC) || die "emake failed"
}

src_install () {
	dobin netselect || die "dobin failed"
	if use !prefix; then
		fowners root:wheel /usr/bin/netselect
		fperms 4711 /usr/bin/netselect
	fi
	dodoc ChangeLog HISTORY README*
}
