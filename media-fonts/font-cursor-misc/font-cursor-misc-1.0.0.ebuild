# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/font-cursor-misc/font-cursor-misc-1.0.0.ebuild,v 1.16 2007/02/04 18:43:35 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular


DESCRIPTION="X.Org cursor font"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RDEPEND=""
DEPEND="${RDEPEND}
	x11-apps/bdftopcf"
