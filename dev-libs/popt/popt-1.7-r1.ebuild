# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.7-r1.ebuild,v 1.26 2007/01/09 19:05:52 sanchan Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="1.6"

inherit libtool eutils flag-o-matic autotools

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://www.rpm.org/"
SRC_URI="ftp://ftp.rpm.org/pub/rpm/dist/rpm-4.1.x/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-missing-tests.patch
	epatch "${FILESDIR}"/${P}-nls.patch
	use nls || touch ../rpm.c

	eautomake
	elibtoolize
}

src_compile() {
	econf $(use_enable nls) || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc CHANGES README
}
