# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrandr/libXrandr-1.3.0.ebuild,v 1.9 2009/11/05 08:56:29 remi Exp $

inherit x-modular

DESCRIPTION="X.Org Xrandr library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
	>=x11-proto/randrproto-1.3
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/renderproto
	x11-proto/xextproto"
