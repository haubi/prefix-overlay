# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/jpeg-6b-r8.ebuild,v 1.5 2007/04/24 19:02:27 armin76 Exp $

EAPI="prefix"

inherit libtool eutils toolchain-funcs

PATCH_VER="1.6"
DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://www.ijg.org/"
SRC_URI="ftp://ftp.uu.net/graphics/jpeg/${PN}src.v${PV}.tar.gz
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/libtool-1.5.10-r4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch
	elibtoolize
}

src_compile() {
	tc-export CC RANLIB AR
	econf \
		--enable-shared \
		--enable-static \
		--enable-maxmem=64 \
		|| die "econf failed"
	emake || die "make failed"
	emake -C "${WORKDIR}"/extra || die "make extra failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install"
	emake -C "${WORKDIR}"/extra install DESTDIR="${D}${EPREFIX}" || die "install extra"

	dodoc README install.doc usage.doc wizard.doc change.log \
		libjpeg.doc example.c structure.doc filelist.doc \
		coderules.doc
}
