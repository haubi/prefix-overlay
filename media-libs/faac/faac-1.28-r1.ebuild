# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.28-r1.ebuild,v 1.13 2012/03/21 09:03:36 ssuominen Exp $

EAPI=2
inherit autotools eutils flag-o-matic

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MPEG-4 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND="~media-libs/libmp4v2-1.9.1"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-external-libmp4v2.patch \
		"${FILESDIR}"/${P}-altivec.patch
	epatch "${FILESDIR}"/${P}-solaris.patch
	eautoreconf
	epunt_cxx
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO
	dohtml docs/*.html
	insinto /usr/share/doc/${PF}/pdf
	doins docs/libfaac.pdf
	find "${D}" -name '*.la' -exec rm -f '{}' +
}
