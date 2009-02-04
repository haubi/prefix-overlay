# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openjpeg/openjpeg-1.3-r1.ebuild,v 1.1 2009/02/03 15:34:37 drizzt Exp $

EAPI="prefix"

inherit eutils toolchain-funcs multilib flag-o-matic

DESCRIPTION="An open-source JPEG 2000 codec written in C"
HOMEPAGE="http://www.openjpeg.org/"
SRC_URI="http://www.openjpeg.org/openjpeg_v${PV//./_}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="tools"
DEPEND="tools? ( >=media-libs/tiff-3.8.2 )"
RDEPEND=${DEPEND}

S="${WORKDIR}/OpenJPEG_v1_3"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2-Makefile.patch
	cp "${FILESDIR}"/${P}-codec-Makefile "${S}"/codec/Makefile
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	# AltiVec on OSX/PPC screws up the build :(
	[[ ${CHOST} == powerpc*-apple-darwin* ]] && filter-flags -m*

	emake CC="$(tc-getCC)" AR="$(tc-getAR)" LIBRARIES="-lm" PREFIX="${EPREFIX}/usr" TARGOS=$(uname) COMPILERFLAGS="${CFLAGS} -std=c99 -fPIC" || die "emake failed"
	if use tools; then
		emake -C codec CC="$(tc-getCC)" || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" TARGOS=$(uname) INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)" install || die "install failed"
	if use tools; then
		emake -C codec DESTDIR="${D}" PREFIX="${EPREFIX}/usr" INSTALL_BINDIR="${EPREFIX}/usr/bin" install || die "install failed"
	fi
	dodoc ChangeLog
}
