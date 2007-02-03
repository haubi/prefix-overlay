# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-proto/xf86dgaproto/xf86dgaproto-2.0.2.ebuild,v 1.15 2006/09/10 08:50:20 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XF86DGA protocol headers"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
