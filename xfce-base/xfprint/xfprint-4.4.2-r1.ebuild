# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfprint/xfprint-4.4.2-r1.ebuild,v 1.1 2008/01/25 07:37:23 drac Exp $

EAPI="prefix"

inherit eutils xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Frontend for printing, management and job queue."
HOMEPAGE="http://www.xfce.org/projects/xfprint"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux"
IUSE="cups debug doc"

RDEPEND="cups? ( net-print/cups )
	!cups? ( !prefix? ( net-print/lprng ) )
	>=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4mcs-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}
	app-text/a2ps"
DEPEND="${RDEPEND}
	dev-util/intltool
	doc? ( dev-util/gtk-doc )"

pkg_setup() {
	if use cups; then
		XFCE_CONFIG="${XFCE_CONFIG} --enable-bsdlpr --enable-cups"
	else
		XFCE_CONFIG="${XFCE_CONFIG} --enable-bsdlpr"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-no-default-printer.patch
}

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_core_package
