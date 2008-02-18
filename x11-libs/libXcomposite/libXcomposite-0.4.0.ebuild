# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXcomposite/libXcomposite-0.4.0.ebuild,v 1.8 2007/09/29 10:22:39 armin76 Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xcomposite library"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~sparc-solaris ~x86-solaris"
RDEPEND="x11-libs/libX11
	x11-libs/libXfixes
	x11-libs/libXext
	>=x11-proto/compositeproto-0.4
	x11-proto/xproto"
DEPEND="${RDEPEND}"
