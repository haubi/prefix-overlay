# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/bigreqsproto/bigreqsproto-1.0.2.ebuild,v 1.16 2007/02/04 18:08:36 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org BigReqs protocol headers"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}"
