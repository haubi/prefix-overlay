# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrender/libXrender-0.9.5.ebuild,v 1.2 2009/11/29 12:33:10 scarabeus Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xrender library"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	>=x11-proto/renderproto-0.9.3
	x11-proto/xproto"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/0001-Make-libXrender-use-docdir-for-documentation-placeme.patch"
)
