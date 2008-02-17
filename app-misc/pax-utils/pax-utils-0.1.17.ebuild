# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pax-utils/pax-utils-0.1.17.ebuild,v 1.1 2008/01/17 06:57:36 solar Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="Various ELF related utils for ELF32, ELF64 binaries useful tools that can check files for security relevant properties"
HOMEPAGE="http://hardened.gentoo.org/pax-utils.xml"
SRC_URI="mirror://gentoo/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~solar/pax/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/pax-utils-${PV}.tar.bz2"
#SRC_URI="http://wh0rd.org/pax-utils-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="caps"
#RESTRICT="mirror"

DEPEND="caps? ( sys-libs/libcap )"

src_compile() {
	emake CC=$(tc-getCC) USE_CAP=$(use caps && echo yes) || die
}

src_install() {
	emake DESTDIR="${D}${EPREFIX}" install || die
	cp lddtree.sh ${ED}/usr/bin/ ; #|| die "dont care"
}
