# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.16.1-r3.ebuild,v 1.6 2006/08/06 16:50:09 vapier Exp $

EAPI="prefix"

PATCHVER="1.10"
UCLIBC_PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x86"

src_unpack() {
	tc-binutils_unpack
	tc-binutils_apply_patches

	cd ${S}
	epatch "${FILESDIR}"/${PN}-2.16-solaris10.patch
}
