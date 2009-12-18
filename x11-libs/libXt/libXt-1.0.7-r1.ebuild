# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXt/libXt-1.0.7-r1.ebuild,v 1.5 2009/12/15 19:39:19 ranger Exp $

SNAPSHOT="yes"

inherit x-modular flag-o-matic toolchain-funcs

DESCRIPTION="X.Org Xt library"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libSM
	x11-libs/libICE
	x11-proto/xproto
	x11-proto/kbproto"
DEPEND="${RDEPEND}"

# no longer apply
#PATCHES=(
#	"${FILESDIR}/libXt-1.0.6-winnt.patch"
#	"${FILESDIR}/libXt-1.0.6-winnt-asm.patch"
#)

PATCHES=( "${FILESDIR}/${P}-fix-cross-compile-again.patch" )

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect

	if tc-is-cross-compiler; then
		export CFLAGS_FOR_BUILD="${BUILD_CFLAGS}"
	fi
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	x-modular_src_compile
}
