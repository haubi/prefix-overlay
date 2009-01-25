# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/linux-headers/linux-headers-2.6.27-r2.ebuild,v 1.8 2009/01/23 11:32:05 armin76 Exp $

EAPI="prefix"

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arm cris hppa m68k mips ia64 ppc ppc64 s390 sh sparc x86"
inherit kernel-2
detect_version

PATCH_VER="2"
SRC_URI="mirror://gentoo/gentoo-headers-base-${PV}.tar.lzma"
[[ -n ${PATCH_VER} ]] && SRC_URI="${SRC_URI} mirror://gentoo/gentoo-headers-${PV}-${PATCH_VER}.tar.lzma"

KEYWORDS="~amd64-linux ~x86-linux"

DEPEND="app-arch/lzma-utils"
RDEPEND=""

S=${WORKDIR}/gentoo-headers-base-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/${PV}
	# workaround #244640
	mkdir arch/sparc64
	touch arch/sparc64/Makefile
}

src_install() {
	kernel-2_src_install
	cd "${ED}"
	egrep -r \
		-e '[[:space:]](asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.
	headers___fix $(find -type f)

	# hrm, build system sucks
	find "${ED}" '(' -name '.install' -o -name '*.cmd' ')' -print0 | xargs -0 rm -f

	# provided by libdrm (for now?)
	rm -rf "${ED}"/usr/include/drm
}

src_test() {
	emake -j1 ARCH=$(tc-arch-kernel) headers_check || die
}
