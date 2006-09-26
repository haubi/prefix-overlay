# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.12-r1.ebuild,v 1.10 2006/09/09 10:09:46 vapier Exp $

EAPI="prefix"

inherit eutils autotools multilib

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.bz2
	doc? ( http://www.libpng.org/pub/png/libpng-manual.txt )"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc"
RESTRICT="mirror" #146921

DEPEND="sys-libs/zlib"

src_unpack() {
	unpack ${P}.tar.bz2
	cd "${S}"
	use doc && cp "${DISTDIR}"/libpng-manual.txt .

	epatch "${FILESDIR}"/1.2.7-gentoo.diff

	# Fixes for #136452
	epatch "${FILESDIR}"/${P}-no-asm.patch
	eautoreconf
}

src_compile() {
	econf || die
	mv pngconf.h pngconf.h.in
	emake pngconf.h || die
	emake || die
}

src_install() {
	make DESTDIR="${EDEST}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO
	use doc && dodoc libpng-manual.txt
}

pkg_postinst() {
	# the libpng authors really screwed around between 1.2.1 and 1.2.3
	if [[ -f ${ROOT}/usr/$(get_libdir)/libpng$(get_libname 3.1.2.1) ]] ; then
		rm -f "${ROOT}"/usr/$(get_libdir)/libpng$(get_libname 3.1.2.1)
	fi
}
