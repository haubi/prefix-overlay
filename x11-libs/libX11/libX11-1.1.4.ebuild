# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.1.4.ebuild,v 1.10 2008/07/03 01:58:04 mr_bones_ Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular toolchain-funcs flag-o-matic

DESCRIPTION="X.Org X11 library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ipv6 xcb"
RDEPEND=">=x11-libs/xtrans-1.0.1
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.6
	xcb? ( >=x11-libs/libxcb-1.0 )"
DEPEND="${RDEPEND}
	x11-proto/xf86bigfontproto
	x11-proto/bigreqsproto
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xcmiscproto
	>=x11-misc/util-macros-0.99.0_p20051007"

CONFIGURE_OPTIONS="$(use_enable ipv6)
	$(use_with xcb)"
# xorg really doesn't like xlocale disabled.
# $(use_enable nls xlocale)

src_unpack() {
	x-modular_src_unpack
	eautoreconf # need new libtool for interix
}

x-modular_src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	x-modular_src_configure
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	x-modular_src_make
}
