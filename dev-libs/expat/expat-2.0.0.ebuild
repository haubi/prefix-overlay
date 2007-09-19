# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.0.0.ebuild,v 1.7 2007/02/11 14:28:12 grobian Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/${P}-test-64bit.patch
	epatch ${FILESDIR}/${P}-test-cpp.patch
	elibtoolize
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc Changes README
	dohtml doc/*
}

pkg_postinst() {
	ewarn "Please note that the soname of the library changed!"
	ewarn "If you are upgrading from a previous version you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn "revdep-rebuild --library libexpat.so.0"
}
