# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/pth/pth-2.0.7-r2.ebuild,v 1.2 2011/01/12 21:56:34 arfrever Exp $

inherit eutils fixheadtails autotools libtool

DESCRIPTION="GNU Portable Threads"
HOMEPAGE="http://www.gnu.org/software/pth/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="debug"

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.0.5-parallelfix.patch
	epatch "${FILESDIR}"/${PN}-2.0.6-ldflags.patch
	epatch "${FILESDIR}"/${PN}-2.0.6-sigstack.patch
	epatch "${FILESDIR}"/${PN}-2.0.7-parallel-install.patch
	epatch "${FILESDIR}"/${PN}-2.0.7-mint.patch
	epatch "${FILESDIR}"/${P}-libs.patch

	ht_fix_file aclocal.m4 configure

	eautoconf
	elibtoolize
}

src_compile() {
	local conf

	[[ ${CHOST} == *-mint* ]] && conf="${conf} --enable-pthread"

	use debug && conf="${conf} --enable-debug"	# have a bug --disable-debug and shared

	econf ${conf} || die
	emake || die
}

src_install() {
	#Parallel install issuse fixed with parallel-install.patch.
	#Submitted upstream on 12-13-2010.
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README THANKS USERS || die
}
