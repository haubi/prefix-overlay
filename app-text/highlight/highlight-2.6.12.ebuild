# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/highlight/highlight-2.6.12.ebuild,v 1.1 2009/02/15 17:58:51 patrick Exp $

WX_GTK_VER=2.6

inherit wxwidgets eutils toolchain-funcs

DESCRIPTION="converts source code to formatted text ((X)HTML, RTF, (La)TeX, XSL-FO, XML) with syntax highlight"
HOMEPAGE="http://www.andre-simon.de"
SRC_URI="http://www.andre-simon.de/zip/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="wxwindows"

DEPEND="wxwindows? ( =x11-libs/wxGTK-2.6* )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.6.9-gcc43.patch
	sed -i \
		-e "s:-O2::" \
		-e "s:CFLAGS:CXXFLAGS:g" \
		src/makefile || die "sed failed."
}

src_compile() {
	emake -f makefile PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ CXX="$(tc-getCXX)" all || die "emake all failed."
	if use wxwindows; then
		need-wxwidgets ansi
		emake -f makefile PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ CXX="$(tc-getCXX)" all-gui || die "emake all-gui failed."
	fi
}

src_install() {
	dodir /usr/bin
	emake -f makefile \
		DESTDIR="${D}" PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ \
		install || die "emake install failed."
	if use wxwindows; then
		emake -f makefile \
			DESTDIR="${D}" PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ \
			install-gui || die "emake install-gui failed."
		doicon src/gui/${PN}.xpm
		make_desktop_entry ${PN}-gui Highlight ${PN} "Utility;TextTools"
	fi
}
