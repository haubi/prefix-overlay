# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-xvmc/eselect-xvmc-0.2.ebuild,v 1.1 2008/10/29 14:37:29 cardoe Exp $

inherit eutils

DESCRIPTION="Manages XvMC implementations"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.10"

src_unpack() {
	cp "${FILESDIR}"/${P}.eselect "${T}"/
	cd "${T}"
	epatch "${FILESDIR}"/${P}.eselect-prefix.patch
	sed -i -e "/^\(LIBDIR\|XVMCCONFIG\)=/s:=:=${EPREFIX}:" ${P}.eselect || die
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${T}"/${P}.eselect xvmc.eselect || die "newins failed"
}
