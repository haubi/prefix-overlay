# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ed/ed-0.9.ebuild,v 1.5 2008/06/22 15:27:44 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Your basic line editor"
HOMEPAGE="http://www.gnu.org/software/ed/"
SRC_URI="mirror://gnu/ed/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-apps/texinfo"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.5-build.patch
}

src_compile() {
	tc-export CC CXX
	# custom configure script ... econf wont work
	./configure \
		--prefix="${EPREFIX}"/ \
		--datadir="${EPREFIX}"/usr/share \
		${EXTRA_ECONF} \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	doman doc/ed.1
	dosym ed.1 /usr/share/man/man1/red.1
	dodoc AUTHORS ChangeLog NEWS README TODO
}
