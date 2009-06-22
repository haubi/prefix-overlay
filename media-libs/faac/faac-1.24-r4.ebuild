# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.24-r4.ebuild,v 1.2 2008/11/30 11:08:27 ssuominen Exp $

inherit libtool eutils autotools flag-o-matic

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

RDEPEND=">=media-libs/libsndfile-1.0.0
	media-libs/libmp4v2"
DEPEND="${RDEPEND}
	!<media-libs/faad2-2.0-r3"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-tracknumber.patch
	epatch "${FILESDIR}"/${P}-as-needed.patch
	epatch "${FILESDIR}"/${P}-fixnoise-hang.patch

	eautoreconf
	elibtoolize
	epunt_cxx
}

src_compile() {
	# altivec stuff triggers a definition of bool which causes faac to fail
	# http://archives.postgresql.org/pgsql-hackers/2005-11/msg00104.php
	[[ ${CHOST} == *-darwin* ]] && \
		filter-flags "-faltivec" "-mabi=altivec" "-maltivec" "-mcpu=*"
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO docs/libfaac.pdf
}
