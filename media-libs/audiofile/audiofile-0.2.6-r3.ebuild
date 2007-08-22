# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/audiofile/audiofile-0.2.6-r3.ebuild,v 1.10 2007/08/10 12:44:34 angelos Exp $

EAPI="prefix"

inherit libtool eutils flag-o-matic

DESCRIPTION="An elegant API for accessing audio files"
HOMEPAGE="http://www.68k.org/~michael/audiofile/"
SRC_URI="http://www.68k.org/~michael/audiofile/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"/sfcommands
	epatch "${FILESDIR}"/sfconvert-eradicator.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-m4.patch
	epatch "${FILESDIR}"/${P}-constantise.patch
	epatch "${FILESDIR}"/${P}-fmod.patch

	### Patch for bug #118600
	epatch "${FILESDIR}"/${PN}-largefile.patch
	elibtoolize
}

src_compile() {
	[[ ${CHOST} == powerpc-*-darwin* ]] \
		&& filter-flags -m* # need to avoid altivec stuff
	econf --enable-largefile || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ACKNOWLEDGEMENTS AUTHORS ChangeLog README TODO NEWS NOTES
}
