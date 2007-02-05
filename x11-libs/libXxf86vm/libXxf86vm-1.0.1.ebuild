# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libXxf86vm/libXxf86vm-1.0.1.ebuild,v 1.10 2006/10/01 17:04:09 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xxf86vm library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-proto/xf86vidmodeproto"
