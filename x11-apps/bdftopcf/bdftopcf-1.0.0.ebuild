# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/bdftopcf/bdftopcf-1.0.0.ebuild,v 1.17 2009/05/05 07:25:54 fauli Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org bdftopcf application"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-winnt"
IUSE=""
RDEPEND="x11-libs/libXfont"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-winnt.patch
)

