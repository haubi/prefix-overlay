# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-netload/xfce4-netload-0.4.0.ebuild,v 1.14 2008/01/06 13:14:10 drac Exp $

EAPI="prefix"

inherit xfce44 eutils autotools

xfce44

DESCRIPTION="Netload panel plugin"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-freebsd ~x86-linux"

DEPEND=">=xfce-extra/xfce4-dev-tools-${XFCE_MASTER_VERSION}
	dev-util/intltool"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-asneeded.patch
	AT_M4DIR="${EPREFIX}"/usr/share/xfce4/dev-tools/m4macros eautoreconf
}

xfce44_goodies_panel_plugin
