# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.26-r1.ebuild,v 1.2 2008/04/15 01:19:05 rbu Exp $

EAPI="prefix"

inherit autotools multilib eutils

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.lzma"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.24-pngconf-setjmp.patch
	epatch "${FILESDIR}"/${P}-CVE-2008-1382.patch #217047
	epatch "${FILESDIR}"/${PN}-1.2.25-interix.patch
	# So we get sane .so versioning on FreeBSD
	#elibtoolize
	eautoreconf # need new libtool for interix
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO
}

pkg_postinst() {
	# the libpng authors really screwed around between 1.2.1 and 1.2.3
	if [[ -f ${EROOT}/usr/$(get_libdir)/libpng$(get_libname 3.1.2.1) ]] ; then
		rm -f "${EROOT}"/usr/$(get_libdir)/libpng$(get_libname 3.1.2.1)
	fi
}
