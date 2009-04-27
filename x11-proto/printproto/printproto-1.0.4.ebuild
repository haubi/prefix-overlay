# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/printproto/printproto-1.0.4.ebuild,v 1.8 2009/04/16 02:29:41 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Print protocol headers"

KEYWORDS="~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	PATCHES="${FILESDIR}"/${P}-winnt.patch
	x-modular_src_unpack
}
