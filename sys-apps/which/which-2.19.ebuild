# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/which/which-2.19.ebuild,v 1.6 2008/03/16 08:41:06 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Prints out location of specified executables that are in your path"
HOMEPAGE="http://www.xs4all.nl/~carlo17/which/"
SRC_URI="http://www.xs4all.nl/~carlo17/which/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-apps/texinfo"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/which-gentoo.patch
	epatch "${FILESDIR}"/which-2.19-remove-readline.patch
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS EXAMPLES NEWS README*
}
