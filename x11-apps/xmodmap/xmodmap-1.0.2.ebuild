# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xmodmap/xmodmap-1.0.2.ebuild,v 1.10 2007/07/02 14:10:12 armin76 Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="utility for modifying keymaps and pointer button mappings in X"

KEYWORDS="~amd64 ~ia64 ~mips ~x86"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"
