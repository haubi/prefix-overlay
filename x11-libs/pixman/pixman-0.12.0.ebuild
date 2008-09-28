# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pixman/pixman-0.12.0.ebuild,v 1.1 2008/09/26 05:34:31 compnerd Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular toolchain-funcs versionator

DESCRIPTION="Low-level pixel manipulation routines"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="altivec mmx sse sse2"

CONFIGURE_OPTIONS="$(use_enable altivec vmx) $(use_enable mmx) \
$(use_enable sse2) --disable-gtk"
# (Open)Solaris /bin/sh is broken (at least on ~x64-solaris)
export CONFIG_SHELL="${EPREFIX}"/bin/bash

pkg_setup() {
	if use sse2 && ! use sse; then
		eerror "You enabled SSE2 but have SSE disabled. This is an invalid"
		eerror "configuration. Either do USE='sse' or USE='-sse2'"
		die "SSE2 selected without SSE"
	fi

	if use sse2 && ! $(version_is_at_least "4.2" "$(gcc-version)"); then
		eerror "SSE2 instructions require GCC 4.2 or higher. Either use"
		eerror "GCC 4.2 or higher or USE='-sse2'"
		die "SSE2 instructions require GCC 4.2 or higher"
	fi
}

src_unpack() {
	x-modular_src_unpack
	cd "${S}"

	epatch "${FILESDIR}"/${P}-sse.patch

	eautoreconf
	elibtoolize
}
