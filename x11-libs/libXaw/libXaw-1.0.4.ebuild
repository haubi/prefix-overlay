# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXaw/libXaw-1.0.4.ebuild,v 1.7 2007/12/19 23:44:36 cla Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit eutils autotools x-modular

DESCRIPTION="X.Org Xaw library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="xprint"

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libXpm
	x11-proto/xproto
	xprint? ( x11-libs/libXp )"
DEPEND="${RDEPEND}
	sys-apps/ed"

CONFIGURE_OPTIONS="$(use_enable xprint xaw8)"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

src_unpack() {
	x-modular_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.0.3-darwin.patch
	eautoreconf
}
