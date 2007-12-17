# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXtst/libXtst-1.0.3.ebuild,v 1.7 2007/12/16 17:53:34 corsair Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xtst library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-proto/recordproto
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/inputproto"
