# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrandr/libXrandr-1.2.1.ebuild,v 1.10 2007/06/24 22:38:09 vapier Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xrandr library"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
	>=x11-proto/randrproto-1.2
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/renderproto"
