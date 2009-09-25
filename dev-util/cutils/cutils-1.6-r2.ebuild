# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cutils/cutils-1.6-r2.ebuild,v 1.8 2009/09/23 17:42:34 patrick Exp $

inherit eutils toolchain-funcs

DESCRIPTION="C language utilities"
HOMEPAGE="http://www.sigala.it/sandro/software.php#cutils"
SRC_URI="http://www.sigala.it/sandro/files/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

src_unpack() {
	unpack  ${A}
	epatch "${FILESDIR}"/${P}-r1-gentoo.diff
	epatch "${FILESDIR}"/${P}-case-insensitive.patch
	cd "${S}"/src/cdecl
	mv cdecl.1 cutils-cdecl.1
	for file in "${S}"/doc/*; do
		sed -e 's/cdecl/cutils-cdecl/g' -i "${file}"
	done
	sed -e 's/Xr cdecl/Xr cutils-cdecl/' -i "${S}"/src/cundecl/cundecl.1
}

src_compile() {
	./configure \
		--host=${CHOST} \
		--prefix="${EPREFIX}"${DESTTREE} \
		--infodir="${EPREFIX}"${DESTTREE}/share/info \
		--mandir="${EPREFIX}"${DESTTREE}/share/man || die

	emake CC="$(tc-getCC)" -j1 || die
}

src_install () {
	make DESTDIR="${D}" install || die

	dodoc COPYRIGHT CREDITS HISTORY INSTALL NEWS README
}

pkg_postinst () {
	elog "cdecl was installed as cutils-cdecl because of a naming conflict with dev-util/cdecl"
}
