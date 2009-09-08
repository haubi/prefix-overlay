# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/euses/euses-2.5.6.ebuild,v 1.6 2009/09/07 13:42:06 armin76 Exp $

inherit flag-o-matic toolchain-funcs autotools

DESCRIPTION="look up USE flag descriptions fast"
HOMEPAGE="http://www.xs4all.nl/~rooversj/gentoo"
SRC_URI="http://www.xs4all.nl/~rooversj/gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc64-solaris"
IUSE=""

DEPEND="
	ppc-aix? ( dev-libs/gnulib )
	sparc-solaris? ( dev-libs/gnulib )
	sparc64-solaris? ( dev-libs/gnulib )
	x86-solaris? ( dev-libs/gnulib )
	x64-solaris? ( dev-libs/gnulib )
"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	eautoconf
}

src_compile() {
	if [[ ${CHOST} == *-aix* || ${CHOST} == *-solaris* ]]; then
		append-cppflags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		export LIBS="-lgnu"
	fi

	econf || die
	emake || die
}

src_install() {
	dobin ${PN} || die
	doman ${PN}.1 || die
	dodoc ChangeLog || die
}
