# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/byacc/byacc-1.9-r2.ebuild,v 1.8 2008/10/28 02:05:57 mr_bones_ Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="the best variant of the Yacc parser generator"
HOMEPAGE="http://dickey.his.com/byacc/byacc.html"
SRC_URI="http://sources.isc.org/devel/tools/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/mkstemp.patch

	# The following patch fixes yacc to run correctly on ia64 (and
	# other 64-bit arches).  See bug 46233
	epatch "${FILESDIR}"/byacc-1.9-ia64.patch

	# avoid stack access error, bug 232005
	epatch "${FILESDIR}"/${P}-CVE-2008-3196.patch
}

src_compile() {
	make PROGRAM=byacc CFLAGS="${CFLAGS}" || die
}

src_install() {
	dobin byacc
	mv yacc.1 byacc.1
	doman byacc.1
	dodoc ACKNOWLEDGEMENTS MANIFEST NEW_FEATURES NOTES README
}
