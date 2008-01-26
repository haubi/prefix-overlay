# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/localepurge/localepurge-0.5.3.3.ebuild,v 1.1 2007/01/21 19:54:33 bass Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Script to recover diskspace wasted for unneeded locale files and localized man pages."
HOMEPAGE="http://www.josealberto.org/blog/index.php?s=localepurge"
SRC_URI="mirror://gentoo/${P}.tbz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND="app-shells/bash"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify localepurge
}

src_install() {
	insinto /var/cache/localepurge
	doins defaultlist
	dosym defaultlist /var/cache/localepurge/localelist
	insinto /etc
	doins locale.nopurge
	dobin localepurge || die
	doman localepurge.8
}
