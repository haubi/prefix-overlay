# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xrdb/xrdb-1.0.4.ebuild,v 1.1 2007/09/08 06:25:44 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X server resource database utility"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND="x11-libs/libXmu
	x11-libs/libX11"
DEPEND="${RDEPEND}"
