# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="ELF related utils for ELF 32/64 binaries that can check files for security relevant properties"
HOMEPAGE="http://hardened.gentoo.org/pax-utils.xml"
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/pax-utils-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="caps"
RESTRICT="mirror"

DEPEND="caps? ( sys-libs/libcap )
	sparc-solaris? ( dev-libs/gnulib )
	sparc64-solaris? ( dev-libs/gnulib )
	x86-solaris? ( dev-libs/gnulib )
	x64-solaris? ( dev-libs/gnulib )
"

src_compile() {
	local libs
	if [[ ${CHOST} == *-solaris* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		libs="-lgnu"
	fi
	emake CC="$(tc-getCC)" LIBS="${libs}" USE_CAP=$(use caps && echo yes) || die
}

src_install() {
	emake DESTDIR="${D}${EPREFIX}" install || die
	newbin lddtree.sh lddtree
}
