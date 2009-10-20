# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/fondu/fondu-20060102.ebuild,v 1.1 2009/10/09 11:11:55 pva Exp $

EAPI="2"

inherit eutils

MY_PV=${PV:2:6}

DESCRIPTION="Utilities for converting between and manipulating mac fonts and unix fonts"
HOMEPAGE="http://fondu.sourceforge.net/"
SRC_URI="http://fondu.sourceforge.net/${PN}_src-${MY_PV}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

S=${WORKDIR}/${PN}-${MY_PV}

src_prepare() {
	sed -e 's:^CFLAGS =:CFLAGS +=:' \
		-e 's:$(CFLAGS) -o:$(CFLAGS) $(LDFLAGS) -o:' \
		-i Makefile.in || die "failed to sed"
	epatch "${FILESDIR}/${P}-build-fix.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	doman *.1
	dodoc README
}
