# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libxkbui/libxkbui-1.0.2.ebuild,v 1.9 2006/09/10 09:11:12 vapier Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xkbui library"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

RDEPEND="x11-libs/libXt
	>=x11-libs/libxkbfile-1.0.3
	x11-proto/kbproto"
DEPEND="${RDEPEND}"
