# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXi/libXi-1.1.2.ebuild,v 1.8 2007/09/29 10:19:35 armin76 Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xi library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	>=x11-proto/inputproto-1.4"

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "Some special keys and keyboard layouts may stop working."
	ewarn "To fix them, recompile xorg-server."
}
