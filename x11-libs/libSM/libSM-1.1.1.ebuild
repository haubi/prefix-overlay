# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libSM/libSM-1.1.1.ebuild,v 1.3 2009/08/14 09:14:57 remi Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org SM library"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="ipv6 elibc_FreeBSD"

RDEPEND=">=x11-libs/libICE-1.0.5
	x11-libs/xtrans
	x11-proto/xproto
	!elibc_FreeBSD? (
		|| ( >=sys-apps/util-linux-2.16 <sys-libs/e2fsprogs-libs-1.41.8 )
	)"
DEPEND="${RDEPEND}"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable ipv6)"
}
