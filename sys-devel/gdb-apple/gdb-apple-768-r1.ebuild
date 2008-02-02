# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils flag-o-matic autotools

DESCRIPTION="Apple branch of the GNU Debugger, 10.5"
HOMEPAGE="http://sources.redhat.com/gdb/"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/gdb-${PV}.tar.gz"

LICENSE="APSL-2 GPL-2"
SLOT="0"

KEYWORDS="~ppc-macos ~x86-macos"

IUSE="nls"

RDEPEND=">=sys-libs/ncurses-5.2-r2
	=dev-db/sqlite-3*"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/gdb-${PV}/src

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-texinfo.patch
	eautoreconf

	sed -e 's/-Wno-long-double//' -i gdb/config/*/macosx.mh
}

src_compile() {
	replace-flags -O? -O2
	# AltiVec stuff kills the compilation
	[[ ${CHOST} == powerpc-*-darwin* ]] && filter-flags -m*
	econf \
		--disable-werror \
		$(use_enable nls) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" libdir=/nukeme includedir=/nukeme install || die
	rm -r "$D"/nukeme || die
	rm -Rf "${ED}"/usr/${CHOST} || die
	mv "${ED}"/usr/bin/gdb ${ED}/
	rm -f "${ED}"/usr/bin/*
	mv "${ED}"/gdb "${ED}"/usr/bin/
}
