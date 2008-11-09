# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-xkb/xfce4-xkb-0.4.3-r1.ebuild,v 1.18 2008/11/08 15:42:15 angelos Exp $

EAPI="prefix"

inherit autotools eutils xfce44

xfce44

DESCRIPTION="XKB layout switching panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
DEPEND="dev-util/pkgconfig
	dev-util/intltool
	x11-proto/kbproto
	dev-util/xfce4-dev-tools"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-libtool.patch
	sed -i -e "/^AC_INIT/s/xkb_version()/xkb_version/" configure.in
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR="${EPREFIX}/usr/share/xfce4/dev-tools/m4macros" eautoreconf
}

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
