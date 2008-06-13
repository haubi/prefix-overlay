# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pixman/pixman-0.11.4-r1.ebuild,v 1.1 2008/06/12 14:56:11 cardoe Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

PATCHES="${FILESDIR}/${PN}-0.11.4-memleak.patch"

inherit x-modular autotools

DESCRIPTION="Low-level pixel manipulation routines"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}
