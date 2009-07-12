# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.26-r1.ebuild,v 1.10 2009/07/10 19:42:29 ssuominen Exp $

inherit libtool eutils autotools flag-o-matic

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE=""
RDEPEND="<media-libs/libmp4v2-1.9.0"
DEPEND="${RDEPEND}
	!<media-libs/faad2-2.0-r3"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-external-libmp4v2.patch"

	eautoreconf
	elibtoolize
	epunt_cxx
}

src_compile() {
	# altivec stuff triggers a definition of bool which causes faac to fail
	# http://archives.postgresql.org/pgsql-hackers/2005-11/msg00104.php
	# note this may be an FSF GCC issue only...
	[[ ${CHOST} == *-darwin* ]] && \
		filter-flags "-faltivec" "-mabi=altivec" "-maltivec" "-mcpu=*"

	filter-flags -ftree-vectorize

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO docs/libfaac.pdf
	dohtml docs/*
}
