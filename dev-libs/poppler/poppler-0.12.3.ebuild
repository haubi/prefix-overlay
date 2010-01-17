# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/poppler/poppler-0.12.3.ebuild,v 1.1 2010/01/15 22:34:35 yngwin Exp $

EAPI=2

POPPLER_MODULE=poppler

inherit poppler

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+abiword +lcms +poppler-data"

DEPEND="
	abiword? ( >=dev-libs/libxml2-2.7.2 )
	lcms? ( >=media-libs/lcms-1.18 )
	>=media-libs/freetype-2.3.7
	>=media-libs/fontconfig-2
	>=media-libs/jpeg-6b
	>=media-libs/openjpeg-1.3-r2
	sys-libs/zlib
	"
RDEPEND="
	${DEPEND}
	poppler-data? ( >=app-text/poppler-data-0.2.1 )
	!<dev-libs/poppler-qt3-${PV}
	!<dev-libs/poppler-qt4-${PV}
	!<dev-libs/poppler-glib-${PV}
	!<app-text/poppler-utils-${PV}
	"

# Is this still needed? (abcd, 2010/01/17)
PATCHES=( "${FILESDIR}"/${PN}-0.12.3-stdbool-darwin.patch )

pkg_setup() {
	POPPLER_CONF="	$(use_enable abiword abiword-output)
			$(use_enable lcms cms)
			--disable-poppler-qt4
			--disable-cairo-output"
	POPPLER_PKGCONFIG=( "poppler-splash.pc" "poppler.pc" )
}

src_compile() {
	for dir in goo fofi splash poppler
	do
		POPPLER_MODULE_S="${S}/${dir}" poppler_src_compile
	done
}

src_install() {
	for dir in goo fofi splash poppler
	do
		POPPLER_MODULE_S="${S}/${dir}" poppler_src_install
	done
}
