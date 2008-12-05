# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/check/check-0.9.5-r1.ebuild,v 1.1 2008/12/05 04:53:47 dirtyepic Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="A unit test framework for C"
HOMEPAGE="http://sourceforge.net/projects/check/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-autotools.patch
	epatch "${FILESDIR}"/${P}-AM_PATH_CHECK.patch
	epatch "${FILESDIR}"/${P}-setup-stats.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	mv "${ED}"/usr/share/doc/{${PN},${PF}} || die
}
