# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxkbfile/libxkbfile-1.0.4.ebuild,v 1.11 2007/08/07 13:18:31 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xkbfile library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND="x11-libs/libX11
	x11-proto/kbproto"
DEPEND="${RDEPEND}"
