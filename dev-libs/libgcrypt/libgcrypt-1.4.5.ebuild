# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.4.5.ebuild,v 1.4 2010/01/19 18:39:33 nixnut Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs autotools

DESCRIPTION="general purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/libgpg-error-1.5"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.4.0-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-1.4.0-interix3.patch

	# remove the included libtool.m4 to force a new libtool
	# to be used.
	rm -f m4/libtool.m4

	AT_M4DIR="m4" eautoreconf # need new libtool for interix
}

src_prepare() {
	epunt_cxx
}

src_configure() {
	# --disable-padlock-support for bug #201917
	# O-flag-mungling: https://bugs.g10code.com/gnupg/issue992
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--with-pic \
		--enable-noexecstack \
		$(use_enable !mips-irix O-flag-munging)
	
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README* THANKS TODO
}
