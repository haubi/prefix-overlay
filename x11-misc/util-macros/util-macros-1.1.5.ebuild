# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/util-macros/util-macros-1.1.5.ebuild,v 1.5 2007/05/04 20:45:25 dang Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org autotools utility macros"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
RDEPEND=""
DEPEND="${RDEPEND}"

PATCHES="${FILESDIR}/1.1.1-driver-man-suffix.patch"
