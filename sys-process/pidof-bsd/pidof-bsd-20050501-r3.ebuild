# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/pidof-bsd/pidof-bsd-20050501-r3.ebuild,v 1.3 2007/07/14 23:02:48 mr_bones_ Exp $

EAPI="prefix"

inherit base toolchain-funcs

DESCRIPTION="pidof(1) utility for *BSD"
HOMEPAGE="http://people.freebsd.org/~novel/pidof.html"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-fbsd ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="!sys-process/psmisc"

S="${WORKDIR}/pidof"

PATCHES="${FILESDIR}/${P}-gfbsd.patch
	${FILESDIR}/${P}-firstarg.patch
	${FILESDIR}/${P}-pname.patch"

[[ ${CHOST} == *-darwin* ]] && \
	PATCHES="${PATCHES} ${FILESDIR}/${P}-darwin.patch"

src_compile() {
	local libs=""
	[[ ${CHOST} == *-*bsd* ]] && libs="-lkvm"
	$(tc-getCC) -o pidof pidof.c ${libs} || die
}

src_install() {
	into /
	dobin pidof
}
