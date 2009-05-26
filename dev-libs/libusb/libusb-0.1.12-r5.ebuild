# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libusb/libusb-0.1.12-r5.ebuild,v 1.8 2009/05/24 18:12:34 maekke Exp $

inherit eutils libtool autotools toolchain-funcs

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI="mirror://sourceforge/libusb/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug doc nocxx"
RESTRICT="test"

RDEPEND="!dev-libs/libusb-compat"
DEPEND="${RDEPEND}
	doc? ( app-text/openjade
	app-text/docbook-dsssl-stylesheets
	app-text/docbook-sgml-utils
	~app-text/docbook-sgml-dtd-4.2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:-Werror::' Makefile.am
	sed -i 's:AC_LANG_CPLUSPLUS:AC_PROG_CXX:' configure.in #213800
	epatch "${FILESDIR}"/${PV}-fbsd.patch
	use nocxx && epatch "${FILESDIR}"/${PN}-0.1.12-nocpp.patch
	epatch "${FILESDIR}"/${PN}-0.1.12-no-infinite-bulk.patch
	eautoreconf
	elibtoolize

	# Ensure that the documentation actually finds the DTD it needs
	docbookdtd="/usr/share/sgml/docbook/sgml-dtd-4.2/docbook.dtd"
	sysid='"-//OASIS//DTD DocBook V4.2//EN"'
	sed -r -i -e \
		"s,(${sysid}) \[\$,\1 \"${docbookdtd}\" \[,g" \
		"${S}"/doc/manual.sgml
}

src_compile() {
	econf \
		--libdir "${EPREFIX}"/usr/$(get_libdir) \
		$(use_enable debug debug all) \
		$(use_enable doc build-docs)
	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS NEWS README
	use doc && dohtml doc/html/*.html

	gen_usr_ldscript -a usb
	use nocxx && rm -f "${ED}"/usr/include/usbpp.h
}
