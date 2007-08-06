# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXtst/libXtst-1.0.2.ebuild,v 1.2 2007/07/14 19:28:57 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xtst library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-proto/recordproto
	x11-libs/libXext"
DEPEND="${RDEPEND}"
