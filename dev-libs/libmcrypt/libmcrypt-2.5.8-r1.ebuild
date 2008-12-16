# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmcrypt/libmcrypt-2.5.8-r1.ebuild,v 1.1 2008/12/15 21:00:17 robbat2 Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="libmcrypt is a library that provides uniform interface to access several encryption algorithms."
HOMEPAGE="http://mcrypt.sourceforge.net/"
SRC_URI="mirror://sourceforge/mcrypt/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/$P-rotate-mask.patch

	eautoreconf # need new libtool for interix (elibtoolize would suffice for freebsd)
}

src_install() {
	make install DESTDIR="${D}" || die "install failure"

	dodoc AUTHORS KNOWN-BUGS INSTALL NEWS README THANKS TODO ChangeLog
	dodoc doc/README.* doc/example.c
	prepalldocs
}
