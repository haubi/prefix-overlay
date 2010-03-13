# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libpaper/libpaper-1.1.23.ebuild,v 1.10 2010/03/08 08:14:49 sping Exp $

inherit eutils autotools

MY_P=${P/-/_}
DESCRIPTION="Library for handling paper characteristics"
HOMEPAGE="http://packages.debian.org/unstable/source/libpaper"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/libpaper-1.1.14.8-malloc.patch
	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${P}-interix-getopt.patch
	eautoreconf # required for interix, was elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog debian/changelog debian/NEWS
	dodir /etc
	(paperconf 2>/dev/null || echo a4) > "${ED}"/etc/papersize
}

pkg_postinst() {
	echo
	elog "run \"paperconfig -p letter\" as root to use letter-pagesizes"
	elog "or paperconf with normal user privileges."
	echo
}
