# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/pth/pth-2.0.7.ebuild,v 1.5 2007/07/22 21:37:38 tgall Exp $

EAPI="prefix"

inherit eutils fixheadtails libtool

DESCRIPTION="GNU Portable Threads"
HOMEPAGE="http://www.gnu.org/software/pth/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-2.0.5-parallelfix.patch"
	epatch "${FILESDIR}/${PN}-2.0.6-ldflags.patch"
	epatch "${FILESDIR}/${PN}-2.0.6-sigstack.patch"
	epatch "${FILESDIR}/${P}-libs.patch"

	ht_fix_file aclocal.m4 configure

	elibtoolize
}

src_compile() {
	local myconf
	use prefix && myconf="--enable-pthread"
	econf ${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README THANKS USERS
}
