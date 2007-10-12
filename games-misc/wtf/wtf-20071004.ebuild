# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/wtf/wtf-20071004.ebuild,v 1.1 2007/10/08 19:03:20 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="translates acronyms for you"
HOMEPAGE="http://www.mu.org/~mux/wtf/"
SRC_URI="http://www.mu.org/~mux/wtf/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"
IUSE=""

DEPEND="!games-misc/bsd-games"
RDEPEND="${DEPEND}
	sys-apps/grep"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-20050505-updates.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify wtf
}

src_install() {
	dobin wtf || die "dogamesbin failed"
	doman wtf.6
	insinto /usr/share/misc
	doins acronyms* || die "doins failed"
}
